package deliled.applications.android.dmx;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import static deliled.applications.android.dmx.SettingsDmx.OperatorName;
import static deliled.applications.android.dmx.SettingsDmx.RoomName;

public class Warningtwo extends Activity {
    Button ValidateWarningTwo, CancelWaningTwo;
    TextView WarningTwoMessage;

    String WarningTwoText;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_warningtwo);
        WarningTwoMessage = findViewById(R.id.warningtwotext);

        ValidateWarningTwo = findViewById(R.id.warningtwovalidate);
        CancelWaningTwo = findViewById(R.id.warningtwodecline);

        WarningTwoText = OperatorName + ", merci de confirmer que vous avez pris les dispositions pour sécuriser et signaler l'opération de désinfection qui va débuter dans la pièce " + RoomName;
        WarningTwoMessage.setText(WarningTwoText);

        ValidateWarningTwo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getBaseContext(), Countdownuvc.class);
                startActivity(intent);
            }
        });
        CancelWaningTwo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
    }

    @Override
    public void onBackPressed() {
        Intent intent1 = new Intent(this, SettingsDmx.class);
        intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent1);
    }

}
