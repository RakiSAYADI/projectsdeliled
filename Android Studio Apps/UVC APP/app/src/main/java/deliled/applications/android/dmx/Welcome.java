package deliled.applications.android.dmx;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.widget.ProgressBar;

import com.github.ybq.android.spinkit.sprite.Sprite;
import com.github.ybq.android.spinkit.style.DoubleBounce;

public class Welcome extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_welcome);

        ProgressBar LoadingProgressBar = findViewById(R.id.spin_kit);
        Sprite doubleBounce = new DoubleBounce();
        LoadingProgressBar.setIndeterminateDrawable(doubleBounce);

        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            public void run() {
                Intent intent = new Intent(getBaseContext(), Scan.class);
                startActivity(intent);
            }
        }, 2000);
    }
}
