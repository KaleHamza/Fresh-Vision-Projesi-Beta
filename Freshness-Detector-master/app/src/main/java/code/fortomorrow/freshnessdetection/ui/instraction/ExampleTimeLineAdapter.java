package code.fortomorrow.freshnessdetection.ui.instraction;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import code.fortomorrow.freshnessdetection.R;
import code.fortomorrow.freshnessdetection.ui.instraction.model.TimeLineModel;

import com.github.vipulasri.timelineview.TimelineView;

import java.util.List;

public class ExampleTimeLineAdapter extends RecyclerView.Adapter<ExampleTimeLineAdapter.TimeLineViewHolder> {

    private final List<TimeLineModel> mFeedList;

    public ExampleTimeLineAdapter(List<TimeLineModel> feedList) {
        mFeedList = feedList;
    }

    @Override
    public int getItemViewType(int position) {
        return TimelineView.getTimeLineViewType(position, getItemCount());
    }

    @NonNull
    @Override
    public TimeLineViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View itemView = inflater.inflate(R.layout.item_timeline, parent, false);
        return new TimeLineViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull TimeLineViewHolder holder, int position) {
        TimeLineModel timeLineModel = mFeedList.get(position);

//        if ("INACTIVE".equals(timeLineModel.getStatus())) {
//            setMarker(holder, R.drawable.ic_marker_inactive, R.color.grey);
//        } else if ("ACTIVE".equals(timeLineModel.getStatus())) {
//            setMarker(holder, R.drawable.ic_marker_active, R.color.grey);
//        } else {
//            setMarker(holder, R.drawable.ic_marker, R.color.grey);
//        }
        holder.timeline.setLineStyle(TimelineView.LineStyle.DASHED);
        holder.timeline.setStartLineColor(R.color.orange,1);

        holder.text_timeline_title.setText(timeLineModel.getMessage());
    }

    private void setMarker(TimeLineViewHolder holder, int drawableResId, int colorResId) {
        Context context = holder.itemView.getContext();
//        holder.timeline.setMarker(VectorDrawableUtils.getDrawable(context, drawableResId, ContextCompat.getColor(context, colorResId)));
    }

    @Override
    public int getItemCount() {
        return mFeedList.size();
    }

    static class TimeLineViewHolder extends RecyclerView.ViewHolder {
        TimelineView timeline;
        TextView text_timeline_date;
        TextView text_timeline_title;

        TimeLineViewHolder(View itemView) {
            super(itemView);
            timeline = itemView.findViewById(R.id.timeline);
            text_timeline_title = itemView.findViewById(R.id.text_timeline_title);
        }
    }
}
