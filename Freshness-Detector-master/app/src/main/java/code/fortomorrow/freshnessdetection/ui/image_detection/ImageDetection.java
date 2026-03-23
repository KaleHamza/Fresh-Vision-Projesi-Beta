package code.fortomorrow.freshnessdetection.ui.image_detection;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import java.util.Objects;
import org.tensorflow.lite.DataType;
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import code.fortomorrow.freshnessdetection.R;
import code.fortomorrow.freshnessdetection.ml.Model;

public class ImageDetection extends AppCompatActivity {
    TextView result, confidence;
    ImageView imageView;
    Button picture,from_gallery;
    int imageSize = 224;
    private static final int PICK_FROM_GALLERY = 101;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        getSupportActionBar().hide();

        setContentView(R.layout.activity_image_detection);
        Objects.requireNonNull(getSupportActionBar())
            .setDisplayOptions(ActionBar.DISPLAY_SHOW_TITLE, ActionBar.DISPLAY_SHOW_TITLE);

        result = findViewById(R.id.result);
        confidence = findViewById(R.id.confidence);
        imageView = findViewById(R.id.imageView);
        picture = findViewById(R.id.button);
        from_gallery = findViewById(R.id.galleryButton);

        picture.setOnClickListener(view -> {
            // Launch camera if we have permission
            if (checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
                Intent cameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                startActivityForResult(cameraIntent, 1);
            } else {
                //Request camera permission if we don't have it.
                requestPermissions(new String[]{Manifest.permission.CAMERA}, 100);
            }
        });
        from_gallery.setOnClickListener(view -> {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                if (checkSelfPermission(Manifest.permission.READ_MEDIA_IMAGES) == PackageManager.PERMISSION_GRANTED) {
                    Intent galleryIntent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                    startActivityForResult(galleryIntent, PICK_FROM_GALLERY);
                } else {
                    requestPermissions(new String[]{Manifest.permission.READ_MEDIA_IMAGES}, PICK_FROM_GALLERY);
                }
            } else {
                if (checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
                    Intent galleryIntent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                    startActivityForResult(galleryIntent, PICK_FROM_GALLERY);
                } else {
                    requestPermissions(new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, PICK_FROM_GALLERY);
                }
            }
        });
    }
    public void classifyImage(Bitmap image){
        try {
            // This line initializes the TensorFlow Lite model.

            Model model = Model.newInstance(getApplicationContext());

            //Creates a TensorBuffer for the model input with fixed size [1, 224, 224, 3] and data type FLOAT32.
            // Creates inputs for reference.
            TensorBuffer inputFeature0 = TensorBuffer.createFixedSize(new int[]{1, 224, 224, 3}, DataType.FLOAT32);
            //
            // Allocates a direct ByteBuffer to hold the image data. The buffer size is 4 * imageSize * imageSize * 3 where 4 is the size of a float in bytes, and 3 is for RGB channels.
            ByteBuffer byteBuffer = ByteBuffer.allocateDirect(4 * imageSize * imageSize * 3);

            //Sets the byte order to the native order of the device.

            byteBuffer.order(ByteOrder.nativeOrder());

            // get 1D array of 224 * 224 pixels in image

            // Creates an array to store the pixel values of the image.
            int [] intValues = new int[imageSize * imageSize];

            // Extracts the pixel values from the Bitmap image into the intValues array.
            image.getPixels(intValues, 0, image.getWidth(), 0, 0, image.getWidth(), image.getHeight());

            // iterate over pixels and extract R, G, and B values. Add to bytebuffer.
            // Initializes a pixel index counter.
            int pixel = 0;
            for(int i = 0; i < imageSize; i++){
                for(int j = 0; j < imageSize; j++){
                    // Gets the RGB value of the current pixel.
                    int val = intValues[pixel++]; // RGB

                    // Extracts and normalizes the R, G, and B values from the pixel and adds them to the byteBuffer.
                    byteBuffer.putFloat(((val >> 16) & 0xFF) * (1.f / 255.f));
                    byteBuffer.putFloat(((val >> 8) & 0xFF) * (1.f / 255.f));
                    byteBuffer.putFloat((val & 0xFF) * (1.f / 255.f));
                }
            }

            //  Loads the byte buffer into the TensorBuffer.
            inputFeature0.loadBuffer(byteBuffer);

            // Runs the model inference with the input buffer.
            // Runs model inference and gets result.
            Model.Outputs outputs = model.process(inputFeature0);

            // Retrieves the output from the model.
            TensorBuffer outputFeature0 = outputs.getOutputFeature0AsTensorBuffer();

            // Converts the output tensor to a float array containing confidence scores for each class.

            float[] confidences = outputFeature0.getFloatArray();
            // find the index of the class with the biggest confidence.
            int maxPos = 0;
//            Initializes variables to track the class with the highest confidence score.
            float maxConfidence = 0;
            String name = "";
            String[] classes = {"Fresh Apple", "Fresh Banana", "Fresh Bitter Guard",
                "Fresh Capsicum", "Fresh Orange", "Fresh Tomato","Stale Apple ",
                    "Stale Banana","Stale Bitter Gourd",
            "Stale Capsicums","Stale Orange","Stale Tomato"

            };
            for(int i = 0; i < confidences.length; i++){
                if(confidences[i] > maxConfidence){
                    maxConfidence = confidences[i];
                    maxPos = i;
                    name = classes[maxPos];
                }
            }

            if(maxConfidence*100 >85.0){
                result.setText(name);
                confidence.setText(String.format(" %.1f%%",maxConfidence*100));
            }
            else {
                result.setText("Can't Define the image");
                confidence.setText("0%");

            }

            String s = "";
            for(int i = 0; i < classes.length; i++){
                s += String.format("%s: %.1f%%\n", classes[i], confidences[i] * 100);
            }


            // Releases model resources if no longer used.
            model.close();
        } catch (IOException e) {
            // TODO Handle the exception
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PICK_FROM_GALLERY) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted, launch the gallery intent again
                Intent galleryIntent =
                    new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                startActivityForResult(galleryIntent, PICK_FROM_GALLERY);
            } else {
                // Permission denied, show a message to the user
                Toast.makeText(this, "Permission to access gallery is required", Toast.LENGTH_SHORT)
                    .show();
            }
        }
    }
    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        if (requestCode == 1 && resultCode == RESULT_OK) {
            Bitmap image = (Bitmap) data.getExtras().get("data");
            int dimension = Math.min(image.getWidth(), image.getHeight());
            image = ThumbnailUtils.extractThumbnail(image, dimension, dimension);
            imageView.setImageBitmap(image);

            image = Bitmap.createScaledBitmap(image, imageSize, imageSize, false);
            classifyImage(image);
        }

        else if (requestCode == PICK_FROM_GALLERY && resultCode == RESULT_OK) {
            Uri selectedImageUri = data.getData();
            try {
                Bitmap image = MediaStore.Images.Media.getBitmap(this.getContentResolver(), selectedImageUri);
                int dimension = Math.min(image.getWidth(), image.getHeight());
                image = ThumbnailUtils.extractThumbnail(image, dimension, dimension);
                imageView.setImageBitmap(image);

                image = Bitmap.createScaledBitmap(image, imageSize, imageSize, false);
                classifyImage(image);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }
}