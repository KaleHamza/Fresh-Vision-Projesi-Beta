import os
import numpy as np
import tensorflow as tf
from flask import Flask, request, jsonify
from rembg import remove
from PIL import Image
import io

app = Flask(__name__)

# --- AYARLAR ---
MODEL_PATH = 'meyve_modeli.h5'
IMG_SIZE = 224
GUVEN_ESIGI = 0.55

# Sınıf Listesi (Eğitimdeki gibi)
MEYVELER = [
    "apple", "banana", "bellpepper", "carrot", "cucumber", 
    "grape", "guava", "jujube", "mango", "orange", 
    "pomegranate", "potato", "strawberry", "tomato","courgette",
    "eggplant","fig","kiwi","lemon","mandarin","peach",
    "pineapple","watermelon"
]
SINIFLAR = []
for meyve in sorted(MEYVELER):
    SINIFLAR.append(f"{meyve}_fresh")
    SINIFLAR.append(f"{meyve}_rotten")

# Raf Ömürleri
RAF_OMURLERI = {
    "apple": 30, "banana": 7, "bellpepper": 14, "carrot": 28,
    "cucumber": 7, "grape": 14, "guava": 5, "jujube": 7,
    "mango": 7, "orange": 21, "pomegranate": 60, "potato": 90,
    "strawberry": 5, "tomato": 10, "courgette":15 , "eggplant" :5,
    "fig" :7, "kiwi":10, "lemon":50, "mandarin":15, "peach":30 , 
    "pineapple":14,"watermelon":5
}

# Modeli Yükle
print("Model yükleniyor...")
model = tf.keras.models.load_model(MODEL_PATH)
print("✅ API Hazır!")

def raf_omru_hesapla(etiket, guven_skoru):
    try:
        parcalar = etiket.split('_')
        meyve_adi = parcalar[0]
        durum = parcalar[1]
    except:
        return 0, 0, "Bilinmiyor"

    max_omur = RAF_OMURLERI.get(meyve_adi, 7)

    if "fresh" in durum:
        saglik_orani = guven_skoru
    elif "rotten" in durum:
        saglik_orani = 1.0 - guven_skoru
        if guven_skoru > 0.9: saglik_orani = 0

    return max_omur * saglik_orani, saglik_orani * 100, meyve_adi

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'Resim yok'}), 400
    
    file = request.files['file']
    
    try:
        # 1. Resmi Okuma ve Temizleme
        input_image = Image.open(file.stream)
        output_image = remove(input_image)
        
        beyaz_fon = Image.new("RGB", output_image.size, (255, 255, 255))
        try:
            beyaz_fon.paste(output_image, mask=output_image.split()[3])
        except:
            beyaz_fon = output_image.convert("RGB")
            
        # 2. Model Tahmini
        img = beyaz_fon.resize((IMG_SIZE, IMG_SIZE))
        img_array = tf.keras.utils.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0) / 255.0
        
        tahmin = model.predict(img_array)
        indeks = np.argmax(tahmin)
        guven = float(np.max(tahmin))
        
        # 3. Sonuç Hazırlama
        if guven < GUVEN_ESIGI:
            return jsonify({
                'success': False,
                'message': 'Tanımlanamadı'
            })
            
        etiket = SINIFLAR[indeks]
        kalan, yuzde, meyve = raf_omru_hesapla(etiket, guven)
        
        return jsonify({
            'success': True,
            'fruit': meyve.upper(),
            'status': 'TAZE' if yuzde > 50 else 'BOZUK',
            'days_left': round(kalan, 1),
            'health_score': int(yuzde),
            'confidence': round(guven * 100, 1)
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # 0.0.0.0 diyerek tüm ağa açıyoruz
    app.run(host='0.0.0.0', port=5000)