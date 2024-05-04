# CropBenchmark

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
