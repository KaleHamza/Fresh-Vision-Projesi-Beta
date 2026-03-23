package code.fortomorrow.freshnessdetection.ui.instraction;

import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import code.fortomorrow.freshnessdetection.R;
import code.fortomorrow.freshnessdetection.ui.instraction.model.TimeLineModel;

import java.util.ArrayList;

public class InstractionFragment extends Fragment {
    private final ArrayList<TimeLineModel> mDataList  = new ArrayList<>();

    private RecyclerView recyclerView;
    public InstractionFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_instraction, container, false);
        recyclerView = view.findViewById(R.id.recyclerViews);
        initRecyclerView();
        setDataListItems();

        return view;
    }
    private void setDataListItems() {
        mDataList.add(new TimeLineModel("Open Camera / Select photo from Gallery", "", "INACTIVE"));
        mDataList.add(new TimeLineModel("Send it for Review", "2017-02-12 08:00", "ACTIVE"));
        mDataList.add(new TimeLineModel("Check Result", "2017-02-10 14:00", "COMPLETED"));
        mDataList.add(new TimeLineModel("Saved this for in Recent Searches", "2017-02-10 14:00", "COMPLETED"));
        mDataList.add(new TimeLineModel("Also Can check in later", "2017-02-10 14:00", "COMPLETED"));
    }

    private void initRecyclerView() {
        LinearLayoutManager mLayoutManager = new LinearLayoutManager(requireActivity(), RecyclerView.VERTICAL, false);
        recyclerView.setLayoutManager(new LinearLayoutManager(requireActivity()));
        ExampleTimeLineAdapter exampleTimeLineAdapter = new ExampleTimeLineAdapter(mDataList);
        recyclerView.setAdapter(exampleTimeLineAdapter);
    }
}