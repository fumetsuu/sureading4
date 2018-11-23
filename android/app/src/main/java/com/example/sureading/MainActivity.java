package com.example.sureading;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.content.Intent;

import java.io.File;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "sureading/dirpicker";

  String mediaPath;

  Result globalResult;

  private void setResult(Result result) {
      globalResult = result;
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);


    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("getDirPath")) {
                    setResult(result);
                    getDirPath();
                } else {
                  result.notImplemented();
                }
              }
            });
  }

  private void getDirPath() {
    Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
    startActivityForResult(intent, 42);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent resultData) {
    super.onActivityResult(requestCode, resultCode, resultData);
    if(requestCode == 42 && resultCode == Activity.RESULT_OK) {
        if(resultData != null) {
            mediaPath = resultData.getData().getPath();
            String fixedMediaPath = fixMediaPath(mediaPath);
            globalResult.success(fixedMediaPath);
        }
    }
  }

  private String fixMediaPath(String mediaPath) {
      if(mediaPath.contains("/tree/primary:")) {
          return mediaPath.replace("/tree/primary:", "/storage/emulated/0/");
      }
      //else must be in the form /tree/<storage device id>:folder
      String sdID = mediaPath.split("/tree/")[1].split(":")[0];
      return "/storage/" + sdID + "/" + mediaPath.split(":")[1];
  }

}
