module batch;

import bindbc.sdl;
import bindbc.opengl;
import core.memory:GC;
import std.file:readText;
import std.string:toStringz;

auto open(string path) {
	return toStringz(readText(path));
}

float* ultraPtrC(float[] data) {
	size_t size = (data.length * float.sizeof);
	float* ar2r = cast(float*) GC.malloc(size);
	
	for (uint i = 0; i < data.length; i++) {
		ar2r = data[i];
	}
	
	return ar2r;
}

struct GPUProgram {
	bool validation;
	uint program;
}

struct GPUData {
	float[2] pos;
	float[4] color;
	
	uint begin;
	uint end;
}

uint gpuCompileShader(uint mode, const char* src) {
	uint shader = glCreateShader(mode);

	glShaderSource(shader, 1, &src, nullptr);
	glCompileShader(shader);
	
	return shader;
}

GPUProgram gpuCreateProgram(string vshPath, string fshPath) {
	auto vshSrc = open(vshPath);
	auto fshSrc = open(fshPath);
	
	GPUProgram gpuProgram;
	
	uint vshShader = gpuCompileShader(GL_VERTEX_SHADER, vshSrc);
	uint fshShader = gpuCompileShader(GL_FRAGMENT_SHADER, fshSrc);
	
	gpuProgram.program = glCreateProgram();
	glAttachShader(gpuProgram.program, vshShader);
	glAttachShader(gpuProgram.program, fshShader);
	glLinkProgram(gpuProgram.program);
	
	return gpuProgram;
}

class Batch {
protected:
	uint concurrentInstancedBuffer;
	uint concurrentInstancedEndBuffer;
	
	uint vertexArrObject;
	uint bufferData;
	
	float[] allocatedVertices;
	float[] allocatedMaterials;
	
	GPUData[] allocatedGPUData;
	uint sizeofAllocatedGPUData;
public:
	this() {}

	void init() {
		glGenVertexArrays(1, &this.vertexArrObject);
		glGenBuffers(1, &this.bufferData);
	}
	
	void invoke() {
		this.concurrentIndexBufferInstance = 0;
	}
	
	void revoke() {
		glBindVertexArrays(this.vertexArrObject);
		
		float* ptrVertices = ultraPtrC(this.allocatedVertices);
		float* ptrMaterials = ultraPtrC(this.allocatedMaterials);
		
		glBindBuffer(GL_ARRAY_BUFFER, this.bufferData);
		glBufferData(GL_ARRAY_BUFFER, float.sizeof * this.allocatedVertices.length, ptrVertices, GL_STATIC_DRAW);
		
		glEnableVertexAttribArray(0);
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, cast(void*) 0);
		
		glEnableVertexAttribArray(1);
		glBufferData(GL_ARRAY_BUFFER, float.sizeof * this.allocatedMaterials.length, ptrMaterials, GL_STATIC_DRAW);
		
		glEnableVertexAttribArray(1);
		glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 3, cast(void*) 3);
		glBindVertexArrays(0);		
	
		this.allocatedMaterials = null;
		this.allocatedVertices = null;
	}
	
	void addVertex(float x, float y) {
		this.allocatedVertices ~= x;
		this.allocatedVertices ~= y;
		this.concurrentInstancedEndBuffer;
	}
	
	void addMaterial(float u, float v) {
		this.allocatedMaterials ~= u;
		this.allocatedMaterials ~= v;
	}

	void call(float posX, float posY, float r, float g, float b, float a) {
		this.allocatedGPUData[this.sizeofAllocatedGPUData].begin = this.concurrentInstancedBuffer;
		this.allocatedGPUData[this.sizeofAllocatedGPUData].pos = [posX, posY];
		this.allocatedGPUData[this.sizeofAllocatedGPUData].color = [r, g, b, a];
	}
	
	void next() {
		this.allocatedGPUData[this.sizeofAllocatedGPUData].end = this.concurrentInstancedEndBuffer;
		this.concurrentInstancedEndBuffer = 0;
		this.sizeofAllocatedGPUData++;
	}
	
	void draw() {	
		GPUData concurrentGPUData;
		
		// Bind VAO.
		glBindVertexArrays(this.vertexArrObject);
	
		for (uint j = 0; j < this.sizeofAllocatedGPUData; j++) {
			concurrentGPUData = this.allocatedGPUData[j];
			
			glDrawArrays(GL_TRIANGLES, concurrentGPUData.begin, concurrentGPUData.end);
		}
		
		glBindVertexArrays(0);
	}
}
