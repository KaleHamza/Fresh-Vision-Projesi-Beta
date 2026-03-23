<h1 align="center">Freshness Detector</h1>    

🗡️ This project is a **Freshness Detector** built using **TensorFlow Lite**, which classifies fruits and vegetables as either **fresh** or **stale**. The model is trained to identify six types of items in both fresh and stale states.

## Screen-shoots

<div style="display: flex; justify-content: center; gap: 10px;">
    <img src="figure/figure1.png" alt="figure1" style="width: 30%;">
    <img src="figure/figure2.png" alt="figure2" style="width: 30%;">
    <img src="figure/figure3.png" alt="figure3" style="width: 30%;">
</div>


## Classes
The model supports the following classes:
- **Fresh Items**:
    1. fresh_apple
    2. fresh_banana
    3. fresh_bitter_gourd
    4. fresh_capsicum
    5. fresh_orange
    6. fresh_tomato

- **Stale Items**:
    1. stale_apple
    2. stale_banana
    3. stale_bitter_gourd
    4. stale_capsicum
    5. stale_orange
    6. stale_tomato

## Project Overview

This project uses **TensorFlow Lite** to build a machine learning model for mobile or edge devices, which can detect the freshness of specific fruits and vegetables based on visual input. The classifier can distinguish between fresh and stale states of apples, bananas, bitter gourds, capsicums, oranges, and tomatoes.

## Features

- **Real-time Detection**: Use the trained model to detect and classify the freshness of items through images.
- **Optimized for Mobile**: TensorFlow Lite allows this model to run efficiently on mobile and embedded devices.
- **Scalability**: The model can be extended to include more fruits or vegetables by retraining with additional data.

## How It Works

1. **Data Preparation**: Images of fresh and stale fruits/vegetables are used to train the model. Each image is labeled with one of the 12 classes listed above.
2. **Model Training**: The TensorFlow model is trained and then converted to a TensorFlow Lite format for optimized deployment on mobile devices.
3. **Inference**: Given an image, the model classifies it into one of the 12 categories (fresh or stale).

## How to Use

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/freshness-detector.git
    ```


4. Use the trained model for inference on new images of fruits and vegetables to determine if they are fresh or stale.

## Model Conversion

The model was trained using TensorFlow and later converted to TensorFlow Lite format for mobile deployment:
```bash
tflite_convert --output_file=model.tflite --graph_def_file=model.pb
