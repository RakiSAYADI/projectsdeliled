package deliled.Applications.android.Maestro;

import android.app.Activity;
import android.bluetooth.BluetoothGattCharacteristic;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.Toast;
import android.widget.ToggleButton;

import java.util.ArrayList;

import static deliled.Applications.android.Maestro.DeviceScanActivity.ACCESS;
import static deliled.Applications.android.Maestro.MainActivity.SSID_modem;
import static deliled.Applications.android.Maestro.MainActivity.Scene_state;
import static deliled.Applications.android.Maestro.MainActivity.Zone_1;
import static deliled.Applications.android.Maestro.MainActivity.Zone_2;
import static deliled.Applications.android.Maestro.MainActivity.Zone_3;
import static deliled.Applications.android.Maestro.MainActivity.Zone_4;
import static deliled.Applications.android.Maestro.MainActivity.bleReadWrite;
import static deliled.Applications.android.Maestro.MainActivity.co2_email;
import static deliled.Applications.android.Maestro.MainActivity.co2_email_enb;
import static deliled.Applications.android.Maestro.MainActivity.co2_enb;
import static deliled.Applications.android.Maestro.MainActivity.co2_notify;
import static deliled.Applications.android.Maestro.MainActivity.co2_val;
import static deliled.Applications.android.Maestro.MainActivity.co2_zone;
import static deliled.Applications.android.Maestro.MainActivity.co2_zone_enb;
import static deliled.Applications.android.Maestro.MainActivity.mConnected;
import static deliled.Applications.android.Maestro.MainActivity.mDeviceAddress;
import static deliled.Applications.android.Maestro.MainActivity.mGattCharacteristics;
import static deliled.Applications.android.Maestro.MainActivity.myswitch;
import static deliled.Applications.android.Maestro.MainActivity.state;
import static deliled.Applications.android.Maestro.MainActivity.write_profils;
import static deliled.Applications.android.Maestro.ajustement_luminosite.isHexNumber;

public class co2 extends Activity {
    public ArrayList<ArrayList<BluetoothGattCharacteristic>> mGattcoCharacteristics = new ArrayList<>();
    public BluetoothLeService mBluetoothLeService;
    private final ServiceConnection mServiceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName componentName, IBinder service) {
            mBluetoothLeService = ((BluetoothLeService.LocalBinder) service).getService();
            if (!mBluetoothLeService.initialize()) {
                finish();
            }
            // Automatically connects to the device upon successful start-up initialization.
            mBluetoothLeService.connect(mDeviceAddress);
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            mBluetoothLeService = null;
        }
    };
    public BluetoothGattCharacteristic mNotifyCharacteristic;
    public int Zone1, Zone2, Zone3, Zone4;
    public Switch alerte_email, alerte_teleph, alerte_zone;
    public EditText values, emai_enter;
    public ToggleButton ZONE_1, ZONE_2, ZONE_3, ZONE_4;
    public Button test_email;
    public MenuItem menuItem;
    public Switch myswitch_co2;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.co2);
        getActionBar().setIcon(R.drawable.lumiair);
        Intent gattServiceIntent = new Intent(this, BluetoothLeService.class);
        bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE);
        mGattcoCharacteristics = mGattCharacteristics;
        getActionBar().setDisplayHomeAsUpEnabled(true);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN | WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE | WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
        alerte_email = findViewById(R.id.switch_email);
        alerte_teleph = findViewById(R.id.switch_tele);
        alerte_zone = findViewById(R.id.switch_zone);
        ZONE_1 = findViewById(R.id.zone1_co2);
        ZONE_2 = findViewById(R.id.zone2_co2);
        ZONE_3 = findViewById(R.id.zone3_co2);
        ZONE_4 = findViewById(R.id.zone4_co2);
        values = findViewById(R.id.valyues);
        emai_enter = findViewById(R.id.emails);
        test_email = findViewById(R.id.emails_button);
        test_email.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (SSID_modem.equals("null")) {
                    Toast.makeText(co2.this, "HuBBox n'est pas connecté à aucun réseau WiFi !", Toast.LENGTH_SHORT).show();
                } else {
                    if (mConnected) {
                        Boolean check = false;
                        do {
                            check = writecharacteristic(3, 0, "{\"test\":\"" + emai_enter.getText().toString() + "\"}");
                        }
                        while (!check);
                    }
                }
            }
        });
        alerte_email.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    emai_enter.setEnabled(true);
                } else {
                    emai_enter.setEnabled(false);
                }
            }
        });
        alerte_zone.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    ZONE_1.setEnabled(true);
                    ZONE_2.setEnabled(true);
                    ZONE_3.setEnabled(true);
                    ZONE_4.setEnabled(true);
                } else {
                    ZONE_1.setEnabled(false);
                    ZONE_2.setEnabled(false);
                    ZONE_3.setEnabled(false);
                    ZONE_4.setEnabled(false);
                }
            }
        });
        read_co2();
    }

    public void read_co2() {

        if (!isHexNumber(co2_zone)) {
            co2_zone = "0";
        }
        int zone = Integer.parseInt(co2_zone, 16);
        int z1 = zone / 8;
        int z2 = zone % 8 / 4;
        int z3 = zone % 4 / 2;
        int z4 = zone % 2;
        if (z4 == 0) {
            ZONE_1.setChecked(false);
        } else {
            ZONE_1.setChecked(true);
        }
        if (z3 == 0) {
            ZONE_2.setChecked(false);
        } else {
            ZONE_2.setChecked(true);
        }
        if (z2 == 0) {
            ZONE_3.setChecked(false);
        } else {
            ZONE_3.setChecked(true);
        }
        if (z1 == 0) {
            ZONE_4.setChecked(false);
        } else {
            ZONE_4.setChecked(true);
        }
        String val_ca2 = "" + co2_val;
        values.setText(val_ca2);
        ZONE_1.setText(Zone_1);
        ZONE_1.setTextOn(Zone_1);
        ZONE_1.setTextOff(Zone_1);
        ZONE_2.setText(Zone_2);
        ZONE_2.setTextOn(Zone_2);
        ZONE_2.setTextOff(Zone_2);
        ZONE_3.setText(Zone_3);
        ZONE_3.setTextOn(Zone_3);
        ZONE_3.setTextOff(Zone_3);
        ZONE_4.setText(Zone_4);
        ZONE_4.setTextOn(Zone_4);
        ZONE_4.setTextOff(Zone_4);
        emai_enter.setText(co2_email);
        if (co2_email_enb == 0) {
            alerte_email.setChecked(false);
        } else {
            alerte_email.setChecked(true);
        }
        if (co2_zone_enb == 0) {
            alerte_zone.setChecked(false);
        } else {
            alerte_zone.setChecked(true);
        }
        if (co2_notify == 0) {
            alerte_teleph.setChecked(false);
        } else {
            alerte_teleph.setChecked(true);
        }

        if (alerte_email.isChecked()) {
            emai_enter.setEnabled(true);
        } else {
            emai_enter.setEnabled(false);
        }
        if (alerte_zone.isChecked()) {
            ZONE_1.setEnabled(true);
            ZONE_2.setEnabled(true);
            ZONE_3.setEnabled(true);
            ZONE_4.setEnabled(true);
        } else {
            ZONE_1.setEnabled(false);
            ZONE_2.setEnabled(false);
            ZONE_3.setEnabled(false);
            ZONE_4.setEnabled(false);
        }

    }

    public boolean writecharacteristic(int i, int j, String data) {
        boolean write = false;
        bleReadWrite = true;
        try {
            final BluetoothGattCharacteristic charac = mGattCharacteristics.get(i).get(j);
            final int charaProp = charac.getProperties();
            byte[] values = data.getBytes();
            charac.setValue(values);
            charac.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
            if ((charaProp | BluetoothGattCharacteristic.PROPERTY_WRITE) > 0) {
                if (mNotifyCharacteristic != null) {
                    mBluetoothLeService.setCharacteristicNotification(mNotifyCharacteristic, false);
                    mNotifyCharacteristic = null;
                }
                write = mBluetoothLeService.writeCharacteristic(charac);
                bleReadWrite = false;
            }
            if ((charaProp | BluetoothGattCharacteristic.PROPERTY_NOTIFY) > 0) {
                mNotifyCharacteristic = charac;
                mBluetoothLeService.setCharacteristicNotification(charac, true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        return write;
    }

    @Override
    public void onBackPressed() {
        write_co2();
        write_profils = false;
        if (state == 0) {
            myswitch.setChecked(false);
        } else {
            myswitch.setChecked(true);
        }
        write_profils = true;
        super.onBackPressed();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.gatt_services_activity, menu);
        if (mConnected) {
            menu.findItem(R.id.menu_connect).setVisible(false);
            menu.findItem(R.id.menu_disconnect).setVisible(true);
        } else {
            menu.findItem(R.id.menu_connect).setVisible(true);
            menu.findItem(R.id.menu_disconnect).setVisible(false);
        }
        menuItem = menu.findItem(R.id.checking);
        menuItem.setActionView(R.layout.actionbar_switcher);
        MAN_AUTO();
        return true;
    }

    public void MAN_AUTO() {
        myswitch_co2 = menuItem.getActionView().findViewById(R.id.manorauto);
        if (state == 0) {
            myswitch_co2.setChecked(false);
        } else {
            myswitch_co2.setChecked(true);
        }
        myswitch_co2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (Scene_state == 1) {
                    Toast.makeText(getApplicationContext(), "Scènes est activé ! ", Toast.LENGTH_LONG).show();
                    state = 0;
                } else {
                    if (isChecked) {
                        if (mConnected) {
                            Boolean check;
                            do {
                                String switching = "{\"mode\":\"auto\"}";
                                state = 1;
                                check = writecharacteristic(3, 0, switching);
                            } while (!check);
                        }
                    } else {
                        if (mConnected) {
                            Boolean check;
                            do {
                                String switching = "{\"mode\":\"manu\"}";
                                state = 0;
                                check = writecharacteristic(3, 0, switching);
                            }
                            while (!check);
                        }
                    }
                }
            }
        });
        if (ACCESS) {
            myswitch_co2.setClickable(true);
        } else {
            myswitch_co2.setClickable(false);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.menu_disconnect:
                Intent i = new Intent(this, DeviceScanActivity.class);
                i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(i);
                return true;
            case android.R.id.home:
                onBackPressed();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void write_co2() {
        if (ZONE_1.isChecked()) {
            Zone1 = 1;
        } else {
            Zone1 = 0;
        }
        if (ZONE_2.isChecked()) {
            Zone2 = 1;
        } else {
            Zone2 = 0;
        }
        if (ZONE_3.isChecked()) {
            Zone3 = 1;
        } else {
            Zone3 = 0;
        }
        if (ZONE_4.isChecked()) {
            Zone4 = 1;
        } else {
            Zone4 = 0;
        }
        co2_zone = Integer.toString((Zone4 * 8) + (Zone3 * 4) + (Zone2 * 2) + Zone1, 16);
        if (co2_zone.equals("null")) {
            co2_zone = "0";
        }
        co2_email = emai_enter.getText().toString();
        if (values.getText().toString().equals("")) {
            co2_val = 0;
        } else {
            co2_val = Integer.valueOf(values.getText().toString());
        }
        if (alerte_teleph.isChecked()) {
            co2_notify = 1;
        } else {
            co2_notify = 0;
        }
        if (alerte_email.isChecked()) {
            co2_email_enb = 1;
        } else {
            co2_email_enb = 0;
        }
        if (alerte_zone.isChecked()) {
            co2_zone_enb = 1;
        } else {
            co2_zone_enb = 0;
        }
        String co2 = "{\"co2\":[" + co2_enb + "," + co2_email_enb + ",\"" + co2_email + "\"," + co2_notify + "," + co2_zone_enb + ",\"" + co2_zone + "\"," + co2_val + "]}";
        if (mConnected) {
            Boolean check = false;
            do {
                check = writecharacteristic(3, 0, co2);
            }
            while (!check);
        }
    }

}
