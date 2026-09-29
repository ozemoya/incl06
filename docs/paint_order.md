# Paint-order experiment

I temporarily moved the hat's `drawRRect` and `drawRect` calls before the filled face circle, hot reloaded, and captured the result on the Android emulator. Most of the hat disappeared behind the face; only the part outside the circle remained visible. I restored the final drawing order with the hat after the face and captured it again. This confirms that later Canvas calls cover earlier ones, so accessories belong near the end of `paint()`.

[Hat behind the face](images/paint-order-hat-behind.png) · [Hat on top](images/paint-order-hat-on-top.png)
