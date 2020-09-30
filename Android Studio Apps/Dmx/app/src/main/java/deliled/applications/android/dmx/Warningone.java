package deliled.applications.android.dmx;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import static deliled.applications.android.dmx.SettingsDmx.OperatorName;
import static deliled.applications.android.dmx.SettingsDmx.RoomName;

public class Warningone extends Activity {

    Button ValidateWarningOne, CancelWaningOne;
    TextView WarningOneMessage;

    String WarningOneText;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_warningone);
        WarningOneMessage = findViewById(R.id.warningonetext);

        ValidateWarningOne = findViewById(R.id.warningonevalidate);
        CancelWaningOne = findViewById(R.id.warningonedecline);

        WarningOneText = OperatorName + ", merci de confirmer que la pièce " + RoomName + " est inoccupée et que vous êtes sorti.";
        WarningOneMessage.setText(WarningOneText);

        ValidateWarningOne.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getBaseContext(), Warningtwo.class);
                startActivity(intent);
            }
        });
        CancelWaningOne.setOnClickListener(new View.OnClickListener() {
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
