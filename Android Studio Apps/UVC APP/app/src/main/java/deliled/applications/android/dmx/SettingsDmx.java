package deliled.applications.android.dmx;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;

public class SettingsDmx extends Activity {

    EditText EstablishmentNameText, OperatorNameText, RoomNameText;
    Spinner DisinfectionTimeSpinner, ActivationDelaySpinner;
    Button ValidateSettings, CancelSettings;

    public static String establishment;
    public static String OperatorName;
    public static String RoomName;
    public static int DisinfectionTime, ActivationDelay;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settingsdmx);

        EstablishmentNameText = findViewById(R.id.establishmentname);
        OperatorNameText = findViewById(R.id.operatorname);
        RoomNameText = findViewById(R.id.roomname);

        DisinfectionTimeSpinner = findViewById(R.id.disinfectionspinner);
        ActivationDelaySpinner = findViewById(R.id.activationdelayspinner);

        ValidateSettings = findViewById(R.id.settingsvalidate);
        CancelSettings = findViewById(R.id.settingsdecline);

        ArrayAdapter<String> AdapterSpinner = new ArrayAdapter<>(this, R.layout.spinner_item, getResources().getStringArray(R.array.delayactivationsecondes));
        AdapterSpinner.setDropDownViewResource(R.layout.drop_list_spinner);
        ActivationDelaySpinner.setAdapter(AdapterSpinner);
        AdapterSpinner = new ArrayAdapter<>(this, R.layout.spinner_item, getResources().getStringArray(R.array.disinfectiontimeminutes));
        AdapterSpinner.setDropDownViewResource(R.layout.drop_list_spinner);
        DisinfectionTimeSpinner.setAdapter(AdapterSpinner);

        ValidateSettings.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                establishment = EstablishmentNameText.getText().toString();
                OperatorName = OperatorNameText.getText().toString();
                RoomName = RoomNameText.getText().toString();

                DisinfectionTime = DisinfectionTimeSpinner.getSelectedItemPosition();
                ActivationDelay = ActivationDelaySpinner.getSelectedItemPosition();

                Intent intent = new Intent(getBaseContext(), Warningone.class);
                startActivity(intent);
            }
        });

        CancelSettings.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent1 = new Intent(SettingsDmx.this, Scan.class);
                intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(intent1);
            }
        });
    }
}
