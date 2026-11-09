package com.example.gujeuk_check_in_flutter_v2

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 구즉은 상시 켜 두는 키오스크라 디스플레이 꺼짐 시간이 지나도 화면을 유지합니다. 법동은 그대로 둡니다.
        if (packageName.endsWith(".gujeuk")) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }
}
