#!/bin/bash
# Proje Hazırlama Betiği

echo "🚀 Meyve Dedektifi - Yerel AI Entegrasyonu"
echo "==========================================="
echo ""

# Adım 1: Bağımlılıkları indir
echo "📦 Adım 1: Bağımlılıklar indiriliyor..."
flutter pub get

# Adım 2: Proje analiz et
echo ""
echo "🔍 Adım 2: Dart analizi çalışıyor..."
flutter analyze

# Adım 3: (İsteğe Bağlı) Test
echo ""
echo "🧪 Adım 3: Testler (opsiyonel)..."
# flutter test

echo ""
echo "✅ Proje hazır! Şu komutla çalıştırın:"
echo "   flutter run"
echo ""
echo "💡 İpucu: Emülatör açık olduğundan emin olun!"
