double getFormatedPercent(double percent) {
  if (percent > 1 && percent <= 100) {
    // convert value discount to 0 <= value <= 1
    percent = percent / 100;
  } else if (percent < 0) {
    percent = percent * -1;
    return getFormatedPercent(percent);
  } else if (percent > 100) {
    percent = 0;
  }
  return percent;
}
