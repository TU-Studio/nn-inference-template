#include "OnnxRuntimeProcessor.h"

OnnxRuntimeProcessor::OnnxRuntimeProcessor() :  memory_info(Ort::MemoryInfo::CreateCpu(OrtDeviceAllocator, OrtMemTypeCPU))
                                                
{
}

OnnxRuntimeProcessor::~OnnxRuntimeProcessor()
{
}

void OnnxRuntimeProcessor::prepareToPlay() {
    session_options.SetIntraOpNumThreads(1);
    session = std::make_unique<Ort::Session>(env, modelpath.c_str(), session_options);
    // Define the shape of input tensor
    inputShape = MODEL_INPUT_SHAPE_ONNX;

    if (WARM_UP) {
        NNInferenceTemplate::InputArray input;
        NNInferenceTemplate::OutputArray output;
        processBlock(input, output);
    }
}

void OnnxRuntimeProcessor::processBlock(NNInferenceTemplate::InputArray& input, NNInferenceTemplate::OutputArray& output) {

    // Create input tensor object from input data values and shape
    const Ort::Value inputTensor = Ort::Value::CreateTensor<float>  (memory_info,
                                                                    input.data(),
                                                                    input.size(),
                                                                    inputShape.data(),
                                                                    inputShape.size());


    // Get input and output names from model
    Ort::AllocatedStringPtr inputName = session->GetInputNameAllocated(0, ort_alloc);
    Ort::AllocatedStringPtr outputName = session->GetOutputNameAllocated(0, ort_alloc);
    inputNames = {(char*) inputName.get()};
    outputNames = {(char*) outputName.get()};

    try {
        // Run inference
        outputTensors = session->Run(Ort::RunOptions{nullptr}, inputNames.data(), &inputTensor, inputNames.size(), outputNames.data(), outputNames.size());
    }
    catch (Ort::Exception &e) {
        std::cout << e.what() << std::endl;
    }

    // Extract the output tensor dat
    for (size_t i = 0; i < BATCH_SIZE * MODEL_OUTPUT_SIZE_BACKEND; i++) {
        output[i] = outputTensors[0].GetTensorMutableData<float>()[i];
    }
}