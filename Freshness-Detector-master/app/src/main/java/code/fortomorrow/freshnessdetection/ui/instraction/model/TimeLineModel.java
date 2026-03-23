package code.fortomorrow.freshnessdetection.ui.instraction.model;

public class TimeLineModel {
    String message,
     date,
     status;

    public TimeLineModel(String message, String date, String status) {
        this.message = message;
        this.date = date;
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
