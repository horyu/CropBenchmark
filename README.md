# CropBenchmark

## 概要

画像のトリミング処理を行うプログラムの処理時間を比較するためのリポジトリです。

## 環境

- CPU: AMD Ryzen 9 3900X 12-Core Processor (24 CPUs), ~3.8GHz
- GPU: NVIDIA GeForce RTX 3060

```text:Windows の仕様
エディション	Windows 10 Pro
バージョン	22H2
インストール日	2021/02/02
OS ビルド	19045.4291
エクスペリエンス	Windows Feature Experience Pack 1000.19056.1000.0
```

```text:CUDA Toolkit
PS C:\Users\owner> nvcc -V
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2024 NVIDIA Corporation
Built on Thu_Mar_28_02:30:10_Pacific_Daylight_Time_2024
Cuda compilation tools, release 12.4, V12.4.131
Build cuda_12.4.r12.4/compiler.34097967_0
```

- 開発環境: Visual Studio 2022 version 17.9.6

## 比較

| プロジェクト | 処理時間 | \[files/s] | \[s/files] |
| --- | --- | --- | --- |
| Cuda | 3.241000 | 61.709349 | 0.016205 |
| OpenCV | 2.201000 | 90.867787 | 0.011005 |


## 画像データセット

[https://placehold.jp/](https://placehold.jp/) を使用させていただきました。WSL上で以下のスクリプトを実行し、200枚の画像をダウンロードしました。

```bash
for i in {001..200}; do
    curl -s -o ${i}.png https://placehold.jp/$(openssl rand -hex 3)/$(openssl rand -hex 3)/2000x1500.png
    sleep 2
done
```

## 外部ライブラリ

本リポジトリは、以下の外部ライブラリのコードを使用しています。

- [dusty-nv/jetson-utils](https://github.com/dusty-nv/jetson-utils)

このライブラリのファイルは `Cuda\jetson-utils` フォルダに配置されています。
ファイルに加えられた変更は、[`git log Cuda\jetson-utils\`](https://github.com/horyu/CropBenchmark/commits/master/Cuda/jetson-utils)をご参照ください。
