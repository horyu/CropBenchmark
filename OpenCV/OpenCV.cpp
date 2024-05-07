#include <stdio.h>
#include <string>
#include <vector>
#include <filesystem>

#include <opencv2/opencv.hpp>

namespace fs = std::filesystem;

using namespace cv;

static std::vector<fs::path> listPngPaths(const std::string& directory)
{
	std::vector<fs::path> paths;
	const fs::path p(directory);
	for (const fs::path p : fs::directory_iterator(p)) {
		if (fs::is_regular_file(p) && p.extension() == ".png") {
			paths.push_back(p);
		}
	}
	return paths;
}

void processImage(const std::string& input_path, const std::string& output_path)
{
	const std::vector<int> params{ IMWRITE_PNG_COMPRESSION , 9 };
	const Mat image = imread(input_path, IMREAD_COLOR);

	int width = image.cols;
	int height = image.rows;

	int x = width / 4;
	int y = height / 3;
	int crop_width = width / 2;
	int crop_height = height / 3;

	const Rect roi(x, y, crop_width, crop_height);

	const Mat cropped = image(roi);
	imwrite(output_path, cropped, params);
}

int main()
{
	const fs::path input_directory = R"(C:\Users\owner\source\repos\CropBenchmark\images)";

	// input_directory\cropped ディレクトリを初期化
	// 存在していたら削除して再作成、存在していなかったら作成
	const fs::path output_directory = input_directory / "cropped";
	if (fs::exists(output_directory)) {
		fs::remove_all(output_directory);
	}
	fs::create_directory(output_directory);
	const std::vector<fs::path> images = listPngPaths(input_directory.string());
	const int size = images.size();

	// ここから時間計測
	const clock_t start = clock();

	for (int i = 0; i < size; i++) {
		const fs::path input_path = images[i];
		//printf("[%d]%s\n", omp_get_thread_num(), input_path.string().c_str());
		const fs::path output_path = output_directory / input_path.filename();
		processImage(input_path.string(), output_path.string());
	}

	const clock_t end = clock();
	const double time = (double)(end - start) / CLOCKS_PER_SEC;
	printf("処理時間   : %f\n", time);
	printf("[files/s]  : %f\n", size / time);
	printf("[s/files]  : %f\n", time / size);

	return 0;
}
