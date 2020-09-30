package deliled.applications.android.dmx;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;
import android.widget.TextView;

import static deliled.applications.android.dmx.CountDownAnimation.NotificationOut;
import static deliled.applications.android.dmx.SettingsDmx.ActivationDelay;
import static deliled.applications.android.dmx.SettingsDmx.DisinfectionTime;
import static deliled.applications.android.dmx.SettingsDmx.OperatorName;
import static deliled.applications.android.dmx.SettingsDmx.RoomName;

public class Countdownuvc extends Activity {
    TextView CountdownActivation;
    TextView CountdownDisinfection;

    ImageButton UrgentStopDisinfection;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_countdownuvc);

        CountdownActivation = findViewById(R.id.countdownactiviation);
        CountdownDisinfection = findViewById(R.id.countdowndisinfection);

        UrgentStopDisinfection = findViewById(R.id.stopbuttondisinfection);

        String CountdownDisinfectionIntNumber = "" + ((DisinfectionTime * 5) + 5);
        CountdownDisinfection.setText(CountdownDisinfectionIntNumber);

        final CountDownAnimation CountDownActivation = new CountDownAnimation(CountdownActivation, ((ActivationDelay + 1) * 10));
        final CountDownAnimation CountDownDisinfection = new CountDownAnimation(CountdownDisinfection, (((DisinfectionTime * 5) + 5) * 60));
        CountDownActivation.start();

        CountDownActivation.setCountDownListener(new CountDownAnimation.CountDownListener() {
            @Override
            public void onCountDownEnd(CountDownAnimation animation) {
                CountDownDisinfection.start();
                CountDownDisinfection.setCountDownListener(new CountDownAnimation.CountDownListener() {
                    @Override
                    public void onCountDownEnd(CountDownAnimation animation) {
                        final AlertDialog.Builder builder = new AlertDialog.Builder(Countdownuvc.this);
                        builder.setMessage("La désinfection de la pièce " + RoomName + " a été réalisée avec succès")
                                .setCancelable(false)
                                .setTitle("Félicitations " + OperatorName)
                                .setNeutralButton("Terminer", new DialogInterface.OnClickListener() {
                                    public void onClick(final DialogInterface dialog, final int id) {
                                        Intent intent1 = new Intent(getBaseContext(), Scan.class);
                                        dialog.cancel();
                                        startActivity(intent1);
                                    }
                                });
                        final AlertDialog alert = builder.create();
                        alert.show();
                        NotificationOut(getClass(),
                                getApplicationContext(),
                                "Félicitations " + OperatorName,
                                "La désinfection de la pièce " + RoomName + " a été réalisée avec succès");
                    }
                });
            }
        });
        UrgentStopDisinfection.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                CountDownActivation.cancel();
                CountDownDisinfection.cancel();
                Intent intent1 = new Intent(getBaseContext(), Scan.class);
                startActivity(intent1);
            }
        });
    }

    @Override
    public void onBackPressed() {

    }
}
