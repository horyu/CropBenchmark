#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <omp.h>

#include <stdio.h>
#include <string>
#include <vector>
#include <filesystem>

#include "logging.h"

#include "imageIO.h"
#include "cudaCrop.h"
#include "cudaMappedMemory.h"

namespace fs = std::filesystem;

class CudaMemory {
public:
	CudaMemory(uchar3* ptr) : ptr_(ptr) {}
	~CudaMemory() { cudaFree(ptr_); }
private:
	uchar3* ptr_;
};

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

void processImage(const char* input_path, const char* output_path)
{
	uchar3* input_image = NULL;
	uchar3* output_image = NULL;
	CudaMemory input_memory(input_image), output_memory(output_image);

	int width = 0, height = 0;

	// Load image
	if (!loadImage(input_path, &input_image, &width, &height)) {
		fprintf(stderr, "[%s] loadImage failed!", input_path);
		return;
	}

	int crop_width = width / 2;
	int crop_height = height / 3;

	// Allocate output image
	if (!cudaAllocMapped(&output_image, sizeof(uchar3) * crop_width * crop_height)) {
		fprintf(stderr, "[%s] cudaAllocMapped failed!", input_path);
		return;
	}

	// Crop image
	int4 roi = {
		width / 4,
		height / 3,
		width / 4 + crop_width,
		height / 3 + crop_height
	};
	cudaError_t cudaStatus = cudaCrop(
		input_image,
		output_image,
		roi,
		width,
		height
	);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "[%s] cudaCrop failed! cudaStatus=%d", input_path, cudaStatus);
		return;
	}

	// Save image
	if (!saveImage(output_path, output_image, crop_width, crop_height)) {
		fprintf(stderr, "[%s] saveImage failed!", input_path);
		return;
	}
}

int main()
{
	Log::SetLevel(Log::Level::SILENT);

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

#pragma omp parallel for
	for (int i = 0; i < size; i++) {
		const fs::path input_path = images[i];
		//printf("[%d]%s\n", omp_get_thread_num(), input_path.string().c_str());
		const fs::path output_path = output_directory / input_path.filename();
		processImage(input_path.string().c_str(), output_path.string().c_str());
	}

	const clock_t end = clock();
	const double time = (double)(end - start) / CLOCKS_PER_SEC;
	printf("処理時間   : %f\n", time);
	printf("[files/s]  : %f\n", size / time);
	printf("[s/files]  : %f\n", time / size);

	return 0;
}
