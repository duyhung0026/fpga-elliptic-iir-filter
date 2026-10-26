#include <SPI.h>
#include <math.h>

#define CS_DAC 15

SPIClass spi(VSPI);
// TEST_MODE = 1: Multi-tone 50 + 2000 + 3000 Hz
// TEST_MODE = 2: Single-tone gần cutoff, chọn SINGLE_FREQ = 150 hoặc 250
// TEST_MODE = 3: DC
#define TEST_MODE 3

// Chỉ dùng khi TEST_MODE = 2
#define SINGLE_FREQ 250.0f
// #define SINGLE_FREQ 250.0f

// THÔNG SỐ LẤY MẪU
const double FS_TARGET = 35511.0;
const double TS_US = 1000000.0 / FS_TARGET;

// THÔNG SỐ DAC
const float MID = 2048.0f;
const float TWO_PI_F = 6.28318530718f;

// TEST 1: MULTI-TONE
// 50 Hz nằm trong dải thông
// 2000 Hz và 3000 Hz nằm vùng suy hao
const float FREQ1 = 50.0f;
const float FREQ2 = 2000.0f;
const float FREQ3 = 3000.0f;

const float AMP1 = 1241.0f;
const float AMP2 = 443.0f;
const float AMP3 = 266.0f;

// TEST 2: SINGLE-TONE
// Dùng để kiểm tra vùng gần cutoff
const float SINGLE_AMP = 1241.0f;

// TEST 3: DC
// DC_CODE = 2048: mức giữa, tương đương AC = 0
// DC_CODE = 2600: mức DC dương để xem bộ lọc có giữ DC không
const int DC_CODE = 2048;

// BIẾN PHA
float ph1 = 0.0f;
float ph2 = 0.0f;
float ph3 = 0.0f;
float ph_single = 0.0f;

const float DPH1 = TWO_PI_F * FREQ1 / (float)FS_TARGET;
const float DPH2 = TWO_PI_F * FREQ2 / (float)FS_TARGET;
const float DPH3 = TWO_PI_F * FREQ3 / (float)FS_TARGET;
const float DPH_SINGLE = TWO_PI_F * SINGLE_FREQ / (float)FS_TARGET;

double nextSampleUs = 0.0;


// GỬI 1 MẪU RA MCP4921
void writeDAC(uint16_t dac_code) {
  dac_code = constrain(dac_code, 0, 4095);

  uint16_t frame = 0x3000 | dac_code;

  digitalWrite(CS_DAC, LOW);
  spi.transfer16(frame);
  digitalWrite(CS_DAC, HIGH);
}


// TẠO MẪU THEO TEST_MODE
uint16_t generateSample() {
  float sig = MID;

#if TEST_MODE == 1

  // Multi-tone: 50 + 2000 + 3000 Hz
  sig = MID
      + AMP1 * sinf(ph1)
      + AMP2 * sinf(ph2)
      + AMP3 * sinf(ph3);

  ph1 += DPH1;
  ph2 += DPH2;
  ph3 += DPH3;

  if (ph1 >= TWO_PI_F) ph1 -= TWO_PI_F;
  if (ph2 >= TWO_PI_F) ph2 -= TWO_PI_F;
  if (ph3 >= TWO_PI_F) ph3 -= TWO_PI_F;

#elif TEST_MODE == 2

  // Single-tone: 150 Hz hoặc 250 Hz
  sig = MID + SINGLE_AMP * sinf(ph_single);

  ph_single += DPH_SINGLE;

  if (ph_single >= TWO_PI_F) ph_single -= TWO_PI_F;

#elif TEST_MODE == 3

  // DC
  sig = (float)DC_CODE;

#else

  sig = MID;

#endif

  int dac_code = (int)roundf(sig);
  dac_code = constrain(dac_code, 0, 4095);

  return (uint16_t)dac_code;
}


// SETUP
void setup() {
  pinMode(CS_DAC, OUTPUT);
  digitalWrite(CS_DAC, HIGH);

  // VSPI: SCK = GPIO18, MISO không dùng, MOSI = GPIO23, CS = GPIO15
  spi.begin(18, -1, 23, 15);

  spi.beginTransaction(SPISettings(20000000, MSBFIRST, SPI_MODE0));

  nextSampleUs = (double)micros();
}


// LOOP
void loop() {
  double nowUs = (double)micros();

  if (nowUs >= nextSampleUs) {

    nextSampleUs += TS_US;

    // Nếu ESP32 bị trễ quá lâu thì kéo lại thời gian
    if (nowUs - nextSampleUs > 1000.0) {
      nextSampleUs = nowUs + TS_US;
    }

    uint16_t dac_code = generateSample();

    writeDAC(dac_code);
  }
}