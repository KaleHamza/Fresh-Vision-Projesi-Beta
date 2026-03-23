"""
Keras H5 modelini TensorFlow Lite formatına dönüştür
"""
import tensorflow as tf
import os

# Model yolu
MODEL_PATH = 'meyve_modeli.h5'
OUTPUT_PATH = 'assets/meyve_modeli.tflite'

# Output klasörü oluştur
os.makedirs('assets', exist_ok=True)

print("Model yükleniyor...")
model = tf.keras.models.load_model(MODEL_PATH)

print("TFLite'a dönüştürülüyor...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_ops = [
    tf.lite.OpsSet.TFLITE_BUILTINS,
    tf.lite.OpsSet.SELECT_TF_OPS
]

tflite_model = converter.convert()

with open(OUTPUT_PATH, 'wb') as f:
    f.write(tflite_model)

print(f"✅ Model başarıyla dönüştürüldü: {OUTPUT_PATH}")
print(f"Model boyutu: {os.path.getsize(OUTPUT_PATH) / (1024*1024):.2f} MB")
