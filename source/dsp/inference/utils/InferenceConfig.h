#ifndef NN_INFERENCE_TEMPLATE_INFERENCECONFIG_H
#define NN_INFERENCE_TEMPLATE_INFERENCECONFIG_H

enum InferenceBackend {
    LIBTORCH,
    ONNX,
    TFLite
};

#define MODEL_INPUT_SIZE 32768

#endif //NN_INFERENCE_TEMPLATE_INFERENCECONFIG_H
