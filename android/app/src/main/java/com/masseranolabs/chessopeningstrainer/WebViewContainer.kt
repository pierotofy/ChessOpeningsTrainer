package com.masseranolabs.chessopeningstrainer

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.webkit.WebView

class WebViewContainer : WebView {
    constructor(context: Context) : super(context)

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)

    constructor(context: Context, attrs: AttributeSet, defStyle: Int) : super(context, attrs, defStyle)

    fun load(){
        this.settings.javaScriptEnabled = true
        this.loadUrl("file:///android_asset/board/index.html?mode=tree")
        this.setBackgroundColor(Color.TRANSPARENT);
    }
}