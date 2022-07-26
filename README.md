# KaleidoscopeOS GSI

[English](https://github.com/xiaoleGun/treble_build_kscope/blob/sunflowerleaf/README-EN.md)

## 前言
Project Kaleidoscope，是一个全新的 Android ROM 项目。注重代码质量，致力于推动本地化、丰富类原生的特色功能，亦有具备丰富经验的开发者协力，希望以开放的姿态为 Android 社区注入新鲜血液。

## 构建
要开始构建KaleidoscopeOS GSI，您需要熟悉[Git和Repo](https://source.android.com/source/using-repo.html)和[How to build a GSI](https://github.com/phhusson/treble_experimentations/wiki/How-to-build-a-GSI%3F).
- 安装依赖
    ```
    sudo apt-get install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev xattr openjdk-11-jdk jq android-sdk-libsparse-utils
    ```
- 新建kscope工作区并进入
    ```
    mkdir kscope-treble && cd kscope-treble
    ```
- 下载本仓库
    ```
    git clone https://github.com/xiaoleGun/treble_build_kscope
    ```
- 完成之后运行脚本:
    ```
    bash treble_build_kscope/build.sh
    ```

## 感谢
- [Project Kaleidoscope](https://github.com/Project-Kaleidoscope)
- [phhusson](https://github.com/phhusson)
- [AndyCGYan](https://github.com/AndyCGYan)
- [ponces](https://github.com/ponces)
