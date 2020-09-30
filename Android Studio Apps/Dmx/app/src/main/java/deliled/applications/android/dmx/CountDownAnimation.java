package deliled.applications.android.dmx;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Handler;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.widget.TextView;

import androidx.core.app.NotificationCompat;

/**
 * Defines a count down animation to be shown on a {@link TextView }.
 *
 * @author Ivan Ridao Freitas
 */
public class CountDownAnimation {

    private TextView mTextView;
    private Animation mAnimation;
    private int mStartCount;
    private int mCurrentCount;
    private CountDownListener mListener;
    private String TextOutput;

    private Handler mHandler = new Handler();

    private final Runnable mCountDown = new Runnable() {
        public void run() {
            if (mCurrentCount > 0) {
                if (mCurrentCount > 60) {
                    TextOutput = (mCurrentCount / 60) + ":" + mCurrentCount % 60;
                    if (mCurrentCount > 3600) {
                        TextOutput = (mCurrentCount / 3600) + ":" + (mCurrentCount / 60) % 60 + ":" + mCurrentCount % 60;
                    }
                } else {
                    TextOutput = mCurrentCount + "";
                }
                mTextView.setText(TextOutput);
                mTextView.startAnimation(mAnimation);
                mCurrentCount--;
            } else {
                mTextView.setText("0");
                if (mListener != null)
                    mListener.onCountDownEnd(CountDownAnimation.this);
            }
        }
    };

    /**
     * <p>
     * Creates a count down animation in the <var>textView</var>, starting from
     * <var>startCount</var>.
     * </p>
     * <p>
     * By default, the class defines a fade out animation, which uses
     * {@link AlphaAnimation } from 1 to 0.
     * </p>
     *
     * @param textView   The view where the count down will be shown
     * @param startCount The starting count number
     */
    public CountDownAnimation(TextView textView, int startCount) {
        this.mTextView = textView;
        this.mStartCount = startCount;

        mAnimation = new AlphaAnimation(1.0f, 0.0f);
        mAnimation.setDuration(1000);
    }

    /**
     * Starts the count down animation.
     */
    public void start() {
        mHandler.removeCallbacks(mCountDown);

        mTextView.setText(mStartCount + "");
        mTextView.setVisibility(View.VISIBLE);

        mCurrentCount = mStartCount;

        mHandler.post(mCountDown);
        for (int i = 1; i <= mStartCount; i++) {
            mHandler.postDelayed(mCountDown, i * 1000);
        }
    }

    /**
     * Cancels the count down animation.
     */
    public void cancel() {
        mHandler.removeCallbacks(mCountDown);

        mTextView.setText("0");
        mTextView.setVisibility(View.GONE);
    }

    /**
     * Sets the animation used during the count down. If the duration of the
     * animation for each number is not set, one second will be defined.
     */
    public void setAnimation(Animation animation) {
        this.mAnimation = animation;
        if (mAnimation.getDuration() == 0)
            mAnimation.setDuration(1000);
    }

    /**
     * Returns the animation used during the count down.
     */
    public Animation getAnimation() {
        return mAnimation;
    }

    /**
     * Sets a new starting count number for the count down animation.
     *
     * @param startCount The starting count number
     */
    public void setStartCount(int startCount) {
        this.mStartCount = startCount;
    }

    /**
     * Returns the starting count number for the count down animation.
     */
    public int getStartCount() {
        return mStartCount;
    }

    /**
     * Binds a listener to this count down animation. The count down listener is
     * notified of events such as the end of the animation.
     *
     * @param listener The count down listener to be notified
     */
    public void setCountDownListener(CountDownListener listener) {
        mListener = listener;
    }

    /**
     * A count down listener receives notifications from a count down animation.
     * Notifications indicate count down animation related events, such as the
     * end of the animation.
     */
    public static interface CountDownListener {
        /**
         * Notifies the end of the count down animation.
         *
         * @param animation The count down animation which reached its end.
         */
        void onCountDownEnd(CountDownAnimation animation);
    }

    public static final String NOTIFICATION_CHANNEL_ID_UPDATE = "disinfection_finished";
    public static NotificationManager NotificationManagerUpdate;
    public static NotificationCompat.Builder BuilderUpdate;

    public static void NotificationOut(Class<?> cls, Context context, String title, String message) {
        Intent resultIntent = new Intent(context, cls);
        resultIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        PendingIntent resultPendingIntent = PendingIntent.getActivity(context,
                1, resultIntent,
                PendingIntent.FLAG_UPDATE_CURRENT);

        BuilderUpdate = new NotificationCompat.Builder(context,NOTIFICATION_CHANNEL_ID_UPDATE);
        BuilderUpdate.setSmallIcon(R.drawable.ic_launcher);
        BuilderUpdate.setContentTitle(title)
                .setAutoCancel(false)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setVibrate((new long[]{1000, 1000, 1000}))
                .setStyle(new NotificationCompat.BigTextStyle()
                        .bigText(message))
                .setContentIntent(resultPendingIntent);

        NotificationManagerUpdate = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel notificationChannel = new NotificationChannel(NOTIFICATION_CHANNEL_ID_UPDATE, "NOTIFICATION_CHANNEL_UPDATE", importance);
            notificationChannel.enableLights(true);
            notificationChannel.setLightColor(Color.RED);
            notificationChannel.enableVibration(true);

            notificationChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
            assert NotificationManagerUpdate != null;
            BuilderUpdate.setChannelId(NOTIFICATION_CHANNEL_ID_UPDATE);
            NotificationManagerUpdate.createNotificationChannel(notificationChannel);
        }
        assert NotificationManagerUpdate != null;
        NotificationManagerUpdate.notify(1 /* Request Code */, BuilderUpdate.build());
    }

}