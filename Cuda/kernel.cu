
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#include "imageIO.h"
#include "cudaCrop.h"
#include "cudaMappedMemory.h"

class CudaMemory {
public:
	CudaMemory(uchar3* ptr) : ptr_(ptr) {}
	~CudaMemory() { cudaFree(ptr_); }
private:
	uchar3* ptr_;
};

int main()
{
	const char* input_path = R"(C:\Users\owner\source\repos\CudaCropTest\CudaCropTest\images\sample-2000x1500.png)";
	const char* output_path = R"(C:\Users\owner\source\repos\CudaCropTest\CudaCropTest\images\test.png)";

	uchar3* input_image = NULL;
	uchar3* output_image = NULL;
	CudaMemory input_memory(input_image), output_memory(output_image);

	int width = 0, height = 0;

	// Load image
	if (!loadImage(input_path, &input_image, &width, &height)) {
		fprintf(stderr, "loadImage failed!");
		return 1;
	}
	printf("Image loaded: %d x %d\n", width, height);

	int crop_width = width / 2;
	int crop_height = height / 3;

	// Allocate output image
	if (!cudaAllocMapped(&output_image, sizeof(uchar3) * crop_width * crop_height)) {
		fprintf(stderr, "cudaAllocMapped failed!");
		return 1;
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
		fprintf(stderr, "cudaCrop failed! cudaStatus=%d", cudaStatus);
		return 1;
	}

	// Save image
	if (!saveImage(output_path, output_image, crop_width, crop_height)) {
		fprintf(stderr, "saveImage failed!");
		return 1;
	}

	return 0;
}
