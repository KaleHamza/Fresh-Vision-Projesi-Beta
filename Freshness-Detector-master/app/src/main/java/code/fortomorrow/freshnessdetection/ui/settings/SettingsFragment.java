package code.fortomorrow.freshnessdetection.ui.settings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;

import code.fortomorrow.freshnessdetection.R;
import code.fortomorrow.freshnessdetection.databinding.FragmentSettingsBinding;


public class SettingsFragment extends Fragment {

  private FragmentSettingsBinding binding;

  public View onCreateView(@NonNull LayoutInflater inflater,
      ViewGroup container, Bundle savedInstanceState) {


    binding = FragmentSettingsBinding.inflate(inflater, container, false);
    View root = binding.getRoot();

    binding.instraction.getRoot().setOnClickListener(view -> NavHostFragment.findNavController(SettingsFragment.this)
        .navigate(R.id.navigation_instraction));


    return root;
  }

  @Override
  public void onDestroyView() {
    super.onDestroyView();
    binding = null;
  }
}