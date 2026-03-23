package code.fortomorrow.freshnessdetection.ui.dashboard;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class DashboardViewModel extends ViewModel {

  private final MutableLiveData<String> mText;

  public DashboardViewModel() {
    mText = new MutableLiveData<>();
    mText.setValue("The recent Image search will be saved in here");
  }

  public LiveData<String> getText() {
    return mText;
  }
}