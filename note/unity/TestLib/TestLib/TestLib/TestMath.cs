using System;
using System.Collections.Generic;

namespace TestLib
{
    public class TestMath
    {
        public static float Lerp(float min, float max, float t) {
            if (min > max) {
                float temp = min;
                min = max;
                max = min;
            }
            if (t > 1.0f) {
                t = 1.0f;
            }

            float ret = min + (max - min) * t;
            return ret;
        }
    }
}
