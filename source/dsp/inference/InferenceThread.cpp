#include "InferenceThread.h"

InferenceThread::InferenceThread(std::counting_semaphore<1000>& s, std::vector<std::unique_ptr<SessionElement>>& ses) : shouldExit(false), globalSemaphore(s), sessions(ses) {
    onnxProcessor.prepareToPlay();
    torchProcessor.prepareToPlay();
    tfliteProcessor.prepareToPlay();
    start();
}

InferenceThread::~InferenceThread() {
    stop();
}

void InferenceThread::start() {
    thread = std::thread(&InferenceThread::run, this);
}

void InferenceThread::run() {
    while (!shouldExit) {
        globalSemaphore.acquire();
        std::cout << "InferenceThread::run() acquired semaphore" << std::endl;
        for (const auto& session : sessions) {
            if (session->sendSemaphore.try_acquire()) {
                for (int i = 0; i < session->inferenceQueue.size(); ++i) {
                    if (session->inferenceQueue[i].waitingForInference.try_acquire()) {
                        inference(session->currentBackend, session->inferenceQueue[i].processedModelInput, session->inferenceQueue[i].rawModelOutputBuffer);
                    }
                    break;
                }
            }
        }
    }
}

void InferenceThread::inference(InferenceBackend backend, NNInferenceTemplate::InputArray &input, NNInferenceTemplate::OutputArray &output) {
    if (backend == ONNX) {
        // onnxProcessor.processBlock(input, output);
        std::cout << "processing data darling" << std::endl;
    } else if (backend == LIBTORCH) {
        torchProcessor.processBlock(input, output);
    } else if (backend == TFLITE) {
        tfliteProcessor.processBlock(input, output);
    }
}


void InferenceThread::stop() {
    shouldExit = true;
    if (thread.joinable())
    {
        thread.join();
    }
}

