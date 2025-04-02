if (absTick & 0x1 != 0) sqrtR = (sqrtR * 0xfffcb933bd6fad37aa2d162d1a594001) >> 128;
if (absTick & 0x2 != 0) sqrtR = (sqrtR * 0xfff97272373d413259a46990580e213a) >> 128;
// ... and so on for each bit position