package deliled.Applications.android.Maestro;

import android.app.Activity;
import android.app.AlertDialog;
import android.bluetooth.BluetoothGattCharacteristic;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Locale;
import java.util.TimeZone;

import static deliled.Applications.android.Maestro.DeviceScanActivity.ACCESS;
import static deliled.Applications.android.Maestro.MainActivity.DNS;
import static deliled.Applications.android.Maestro.MainActivity.GATE_WAY;
import static deliled.Applications.android.Maestro.MainActivity.IP;
import static deliled.Applications.android.Maestro.MainActivity.MASK;
import static deliled.Applications.android.Maestro.MainActivity.SSID_modem;
import static deliled.Applications.android.Maestro.MainActivity.Scene_state;
import static deliled.Applications.android.Maestro.MainActivity.Summer_time;
import static deliled.Applications.android.Maestro.MainActivity.UDP_enb;
import static deliled.Applications.android.Maestro.MainActivity.UDP_idp4_idp6;
import static deliled.Applications.android.Maestro.MainActivity.UDP_port;
import static deliled.Applications.android.Maestro.MainActivity.UDP_server;
import static deliled.Applications.android.Maestro.MainActivity.adress_ftp;
import static deliled.Applications.android.Maestro.MainActivity.adress_mqtt;
import static deliled.Applications.android.Maestro.MainActivity.bleReadWrite;
import static deliled.Applications.android.Maestro.MainActivity.client_id_ftp;
import static deliled.Applications.android.Maestro.MainActivity.ftp_enb;
import static deliled.Applications.android.Maestro.MainActivity.ftp_now_or_later;
import static deliled.Applications.android.Maestro.MainActivity.ftp_time_send_heure;
import static deliled.Applications.android.Maestro.MainActivity.ftp_time_send_minute;
import static deliled.Applications.android.Maestro.MainActivity.ftp_timeout;
import static deliled.Applications.android.Maestro.MainActivity.ip_enb;
import static deliled.Applications.android.Maestro.MainActivity.mGattCharacteristics;
import static deliled.Applications.android.Maestro.MainActivity.mqtt_enb;
import static deliled.Applications.android.Maestro.MainActivity.mqtt_time_sec;
import static deliled.Applications.android.Maestro.MainActivity.myswitch;
import static deliled.Applications.android.Maestro.MainActivity.pass_ftp;
import static deliled.Applications.android.Maestro.MainActivity.pass_mqtt;
import static deliled.Applications.android.Maestro.MainActivity.pir;
import static deliled.Applications.android.Maestro.MainActivity.port_ftp;
import static deliled.Applications.android.Maestro.MainActivity.port_mqtt;
import static deliled.Applications.android.Maestro.MainActivity.soustopic_mqtt;
import static deliled.Applications.android.Maestro.MainActivity.state;
import static deliled.Applications.android.Maestro.MainActivity.topic_mqtt;
import static deliled.Applications.android.Maestro.MainActivity.tz;
import static deliled.Applications.android.Maestro.MainActivity.user_ftp;
import static deliled.Applications.android.Maestro.MainActivity.user_mqtt;
import static deliled.Applications.android.Maestro.MainActivity.write_access;

public class serveur_access extends Activity {
    public Spinner a, sous_topic, time_mqtt, ftp_duration, ftp_time_minute, ftp_time_heure;
    public String x = TimeZone.getDefault().getDisplayName(false, TimeZone.SHORT, Locale.getDefault());
    private String[] arraySpinnertimezone = new String[25];
    public ArrayAdapter<String> adapter_timezone;
    public boolean mConnected = true;
    public Switch ftp_bool_sending, udp_4or6;
    public String mDeviceAddress;
    public BluetoothGattCharacteristic mNotifyCharacteristic;
    public BluetoothLeService mBluetoothLeService;
    public EditText servftp, portftp, userftp, passftp, brokermqt, portmqt, usermqt, passmqt, topicmqt, pIr, ip, mask, gate, dns, Client_id_ftp, udp_server, udp_port;
    public ArrayList<ArrayList<BluetoothGattCharacteristic>> mGattaCharacteristics = new ArrayList<>();
    public CheckBox FTP, MQTT, SUMMER, IP_enb, udp_enb;
    public TextView ftp_day, ftp_time, ftp_time_;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.avancee);
        getActionBar().setIcon(R.drawable.lumiair);
        time_zone();
        getActionBar().setTitle("Cloud");
        mGattaCharacteristics = mGattCharacteristics;
        a = findViewById(R.id.spinnertime);
        time_mqtt = findViewById(R.id.mqttedit7);
        sous_topic = findViewById(R.id.mqttedit6);
        ftp_duration = findViewById(R.id.ftpedit6);
        ftp_time_heure = findViewById(R.id.ftpedit7);
        ftp_time_minute = findViewById(R.id.ftpedit8);
        Client_id_ftp = findViewById(R.id.ftpedit5);
        ftp_bool_sending = findViewById(R.id.ftp9);
        udp_enb = findViewById(R.id.udp);
        udp_4or6 = findViewById(R.id.udp1);
        udp_server = findViewById(R.id.udpedit);
        udp_port = findViewById(R.id.udpedit2);
        ftp_day = findViewById(R.id.ftp7);
        ftp_time = findViewById(R.id.ftp6);
        ftp_time_ = findViewById(R.id.ftp8);
        Intent gattServiceIntent = new Intent(this, BluetoothLeService.class);
        bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE);
        Intent intent = getIntent();
        mDeviceAddress = intent.getStringExtra(MainActivity.mDeviceAddress);
        getActionBar().setDisplayHomeAsUpEnabled(true);
        adapter_timezone = new ArrayAdapter<>(serveur_access.this, R.layout.spinner_item, arraySpinnertimezone);
        adapter_timezone.setDropDownViewResource(R.layout.drop_list_spinner);
        a.setAdapter(adapter_timezone);
        adapter_timezone = new ArrayAdapter<>(serveur_access.this, R.layout.spinner_item, getResources().getStringArray(R.array.sous_topic));
        adapter_timezone.setDropDownViewResource(R.layout.drop_list_spinner);
        sous_topic.setAdapter(adapter_timezone);
        adapter_timezone = new ArrayAdapter<>(serveur_access.this, R.layout.spinner_item, getResources().getStringArray(R.array.mqtt_second));
        adapter_timezone.setDropDownViewResource(R.layout.drop_list_spinner);
        time_mqtt.setAdapter(adapter_timezone);
        adapter_timezone = new ArrayAdapter<>(serveur_access.this, R.layout.spinner_item, getResources().getStringArray(R.array.ftp_time));
        adapter_timezone.setDropDownViewResource(R.layout.drop_list_spinner);
        ftp_duration.setAdapter(adapter_timezone);
        adapter_timezone = new ArrayAdapter<>(serveur_access.this, R.layout.spinner_item, getResources().getStringArray(R.array.heure));
        adapter_timezone.setDropDownViewResource(R.layout.drop_list_spinner);
        ftp_time_heure.setAdapter(adapter_timezone);
        adapter_timezone = new ArrayAdapter<>(serveur_access.this, R.layout.spinner_item, getResources().getStringArray(R.array.minute));
        adapter_timezone.setDropDownViewResource(R.layout.drop_list_spinner);
        ftp_time_minute.setAdapter(adapter_timezone);
        servftp = findViewById(R.id.ftpedit);
        portftp = findViewById(R.id.ftpedit2);
        userftp = findViewById(R.id.ftpedit3);
        passftp = findViewById(R.id.ftpedit4);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN | WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE | WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
        brokermqt = findViewById(R.id.mqttedit);
        portmqt = findViewById(R.id.mqttedit2);
        usermqt = findViewById(R.id.mqttedit3);
        passmqt = findViewById(R.id.mqttedit4);
        topicmqt = findViewById(R.id.mqttedit5);
        IP_enb = findViewById(R.id.ip);
        SUMMER = findViewById(R.id.Summer);
        ip = findViewById(R.id.IP_ADDRESS);
        mask = findViewById(R.id.MASK);
        gate = findViewById(R.id.GATEWAY);
        dns = findViewById(R.id.DNS);
        pIr = findViewById(R.id.PIR);
        FTP = findViewById(R.id.log);
        MQTT = findViewById(R.id.mqtt);
        if (SSID_modem.equals("null")) {
            SUMMER.setVisibility(View.GONE);
        } else {
            SUMMER.setVisibility(View.VISIBLE);
        }
        read_avancee();

        detect_time_zone();
        SUMMER.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (SUMMER.isChecked()) {
                    Summer_time = 1;
                } else {
                    Summer_time = 0;
                }
            }
        });
        udp_enb.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (udp_enb.isChecked()) {
                    udp_4or6.setEnabled(true);
                    udp_server.setEnabled(true);
                    udp_port.setEnabled(true);
                } else {
                    udp_4or6.setEnabled(false);
                    udp_server.setEnabled(false);
                    udp_port.setEnabled(false);
                }
            }
        });
        IP_enb.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (IP_enb.isChecked()) {
                    ip.setEnabled(true);
                    mask.setEnabled(true);
                    gate.setEnabled(true);
                    dns.setEnabled(true);
                } else {
                    ip.setEnabled(false);
                    mask.setEnabled(false);
                    gate.setEnabled(false);
                    dns.setEnabled(false);
                }
            }
        });
        FTP.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (FTP.isChecked()) {
                    servftp.setEnabled(true);
                    portftp.setEnabled(true);
                    userftp.setEnabled(true);
                    passftp.setEnabled(true);
                    ftp_bool_sending.setEnabled(true);
                    ftp_time_heure.setEnabled(true);
                    ftp_time_minute.setEnabled(true);
                    ftp_duration.setEnabled(true);
                    checking_ftp_time();
                } else {
                    servftp.setEnabled(false);
                    portftp.setEnabled(false);
                    userftp.setEnabled(false);
                    passftp.setEnabled(false);
                    ftp_bool_sending.setEnabled(false);
                    ftp_time_heure.setEnabled(false);
                    ftp_time_minute.setEnabled(false);
                    ftp_duration.setEnabled(false);
                }
            }
        });
        MQTT.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (MQTT.isChecked()) {
                    brokermqt.setEnabled(true);
                    portmqt.setEnabled(true);
                    usermqt.setEnabled(true);
                    passmqt.setEnabled(true);
                    topicmqt.setEnabled(true);
                    sous_topic.setEnabled(true);
                    time_mqtt.setEnabled(true);
                } else {
                    brokermqt.setEnabled(false);
                    portmqt.setEnabled(false);
                    usermqt.setEnabled(false);
                    passmqt.setEnabled(false);
                    topicmqt.setEnabled(false);
                    sous_topic.setEnabled(false);
                    time_mqtt.setEnabled(false);
                }
            }
        });
        ftp_bool_sending.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (ftp_bool_sending.isChecked()) {
                    ftp_time_heure.setEnabled(false);
                    ftp_time_minute.setEnabled(false);
                    ftp_duration.setEnabled(true);
                    ftp_time_heure.setVisibility(View.GONE);
                    ftp_time_minute.setVisibility(View.GONE);
                    ftp_duration.setVisibility(View.VISIBLE);
                    ftp_time.setVisibility(View.VISIBLE);
                    ftp_day.setVisibility(View.GONE);
                    ftp_time_.setVisibility(View.GONE);
                } else {
                    ftp_time_heure.setEnabled(true);
                    ftp_time_minute.setEnabled(true);
                    ftp_duration.setEnabled(false);
                    ftp_time_heure.setVisibility(View.VISIBLE);
                    ftp_time_minute.setVisibility(View.VISIBLE);
                    ftp_duration.setVisibility(View.GONE);
                    ftp_time.setVisibility(View.GONE);
                    ftp_day.setVisibility(View.VISIBLE);
                    ftp_time_.setVisibility(View.VISIBLE);
                }
            }
        });
        SUMMER.setVisibility(View.GONE);
    }

    public boolean check_edittext(EditText editText) {
        if (editText.getText().toString().equals("\"")) {
            Toast.makeText(serveur_access.this, "Le caractére (\") n'est pas autorisé dans cette application !", Toast.LENGTH_SHORT).show();
            return false;
        } else {
            return true;
        }
    }

    boolean access_send = true;

    public void write_config() {
        String adv_cfg_str = "{";

        String pir;

        if (pIr.getText().length() == 0) pir = "0";
        else pir = pIr.getText().toString();

        adv_cfg_str += "\"pir\":" + pir;
        timezone_check();
        adv_cfg_str += ",\"tz\":\"" + a.getSelectedItem() + "\"";

        if (SUMMER.isChecked()) {
            adv_cfg_str += ",\"summer\":1";
        } else {
            adv_cfg_str += ",\"summer\":0";
        }

        if (FTP.isChecked()) {
            adv_cfg_str += ",\"ftp\":[1,";
        } else {
            adv_cfg_str += ",\"ftp\":[0,";
        }

        adv_cfg_str += "\"" + servftp.getText().toString() + "\",";
        adv_cfg_str += "\"" + portftp.getText().toString() + "\",";
        adv_cfg_str += "\"" + userftp.getText().toString() + "\",";
        adv_cfg_str += "\"" + passftp.getText().toString() + "\",";
        adv_cfg_str += "\"" + Client_id_ftp.getText().toString() + "\",";
        if (ftp_bool_sending.isChecked()) {
            adv_cfg_str += "1,";
        } else {
            adv_cfg_str += "0,";
        }
        adv_cfg_str += "" + ftp_duration.getSelectedItemPosition() + ",";
        adv_cfg_str += "" + format(ftp_time_heure.getSelectedItemPosition()) + "" + format(ftp_time_minute.getSelectedItemPosition()) + "],";

        if (IP_enb.isChecked()) {
            adv_cfg_str += "\"IP_STATIC\":[1,";
        } else {
            adv_cfg_str += "\"IP_STATIC\":[0,";
        }

        adv_cfg_str += "\"" + ip.getText().toString() + "\",";
        adv_cfg_str += "\"" + mask.getText().toString() + "\",";
        adv_cfg_str += "\"" + gate.getText().toString() + "\",";
        adv_cfg_str += "\"" + dns.getText().toString() + "\"],";

        if (MQTT.isChecked()) {
            adv_cfg_str += "\"mqtt\":[1,";
        } else {
            adv_cfg_str += "\"mqtt\":[0,";
        }

        String sous_topic_string = "";

        if (sous_topic.getSelectedItemPosition() == 0) {
            sous_topic_string = "all";
        }
        if (sous_topic.getSelectedItemPosition() == 1) {
            sous_topic_string = "temp";
        }
        if (sous_topic.getSelectedItemPosition() == 2) {
            sous_topic_string = "humid";
        }
        if (sous_topic.getSelectedItemPosition() == 3) {
            sous_topic_string = "lux";
        }
        if (sous_topic.getSelectedItemPosition() == 4) {
            sous_topic_string = "co2";
        }
        if (sous_topic.getSelectedItemPosition() == 5) {
            sous_topic_string = "tvoc";
        }
        adv_cfg_str += "\"" + brokermqt.getText().toString() + "\",";
        adv_cfg_str += "\"" + portmqt.getText().toString() + "\",";
        adv_cfg_str += "\"" + usermqt.getText().toString() + "\",";
        adv_cfg_str += "\"" + passmqt.getText().toString() + "\",";
        adv_cfg_str += "\"" + topicmqt.getText().toString() + "\",";
        adv_cfg_str += "\"" + sous_topic_string + "\"," + time_mqtt.getSelectedItem() + "],";

        if (udp_enb.isChecked()) {
            adv_cfg_str += "\"UDP\":[1,";
        } else {
            adv_cfg_str += "\"UDP\":[0,";
        }
        if (udp_4or6.isChecked()) {
            adv_cfg_str += "1,";
        } else {
            adv_cfg_str += "0,";
        }

        adv_cfg_str += "\"" + udp_server.getText().toString() + "\",";
        adv_cfg_str += "" + udp_port.getText().toString() + "]";

        adv_cfg_str += "}";
        read_serveur();
        if (mConnected) {
            Boolean check = false;

            do {
                access_send = check_edittext(pIr) & check_edittext(servftp) & check_edittext(portftp) & check_edittext(userftp) & check_edittext(passftp) & check_edittext(Client_id_ftp)
                        & check_edittext(ip) & check_edittext(mask) & check_edittext(gate) & check_edittext(dns) & check_edittext(brokermqt) & check_edittext(portmqt) & check_edittext(usermqt)
                        & check_edittext(passmqt) & check_edittext(topicmqt) & check_edittext(udp_server) & check_edittext(udp_port);
                if (!access_send) {
                    break;
                }
                check = writecharacteristic(3, 0, adv_cfg_str);
                if (check) {
                    Toast.makeText(serveur_access.this, "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                }

            }
            while (!check);
        }

    }

    public String format(int x) {
        return String.format("%02d", x);
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

    public void timezone_check() {
        if (String.valueOf(a.getSelectedItem()).equals("GMT -12")) tz = -12;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -11")) tz = -11;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -10")) tz = -10;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -9")) tz = -9;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -8")) tz = -8;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -7")) tz = -7;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -6")) tz = -6;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -5")) tz = -5;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -4")) tz = -4;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -3")) tz = -3;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -2")) tz = -2;
        if (String.valueOf(a.getSelectedItem()).equals("GMT -1")) tz = -1;
        if (String.valueOf(a.getSelectedItem()).equals("GMT 0")) tz = 0;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +1")) tz = 1;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +2")) tz = 2;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +3")) tz = 3;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +4")) tz = 4;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +5")) tz = 5;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +6")) tz = 6;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +7")) tz = 7;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +8")) tz = 8;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +9")) tz = 9;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +10")) tz = 10;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +11")) tz = 11;
        if (String.valueOf(a.getSelectedItem()).equals("GMT +12")) tz = 12;
    }

    public void read_serveur() {

        if (SUMMER.isChecked()) {
            Summer_time = 1;
        } else {
            Summer_time = 0;
        }
        if (a.getSelectedItemPosition() == 0) tz = -12;
        if (a.getSelectedItemPosition() == 1) tz = -11;
        if (a.getSelectedItemPosition() == 2) tz = -10;
        if (a.getSelectedItemPosition() == 3) tz = -9;
        if (a.getSelectedItemPosition() == 4) tz = -8;
        if (a.getSelectedItemPosition() == 5) tz = -7;
        if (a.getSelectedItemPosition() == 6) tz = -6;
        if (a.getSelectedItemPosition() == 7) tz = -5;
        if (a.getSelectedItemPosition() == 8) tz = -4;
        if (a.getSelectedItemPosition() == 9) tz = -3;
        if (a.getSelectedItemPosition() == 10) tz = -2;
        if (a.getSelectedItemPosition() == 11) tz = -1;
        if (a.getSelectedItemPosition() == 12) tz = 0;
        if (a.getSelectedItemPosition() == 13) tz = 1;
        if (a.getSelectedItemPosition() == 14) tz = 2;
        if (a.getSelectedItemPosition() == 15) tz = 3;
        if (a.getSelectedItemPosition() == 16) tz = 4;
        if (a.getSelectedItemPosition() == 17) tz = 5;
        if (a.getSelectedItemPosition() == 18) tz = 6;
        if (a.getSelectedItemPosition() == 19) tz = 7;
        if (a.getSelectedItemPosition() == 20) tz = 8;
        if (a.getSelectedItemPosition() == 21) tz = 9;
        if (a.getSelectedItemPosition() == 22) tz = 10;
        if (a.getSelectedItemPosition() == 23) tz = 11;
        if (a.getSelectedItemPosition() == 24) tz = 12;
        pir = Integer.valueOf(pIr.getText().toString());
        if (FTP.isChecked()) {
            ftp_enb = 1;
        } else {
            ftp_enb = 0;
        }
        adress_ftp = servftp.getText().toString();
        port_ftp = portftp.getText().toString();
        user_ftp = userftp.getText().toString();
        pass_ftp = passftp.getText().toString();
        client_id_ftp = Client_id_ftp.getText().toString();
        if (ftp_bool_sending.isChecked()) {
            ftp_now_or_later = 1;
        } else {
            ftp_now_or_later = 0;
        }
        ftp_time_send_heure = ftp_time_heure.getSelectedItemPosition();
        ftp_time_send_minute = ftp_time_minute.getSelectedItemPosition();
        ftp_timeout = ftp_duration.getSelectedItemPosition();

        if (IP_enb.isChecked()) {
            ip_enb = 1;
        } else {
            ip_enb = 0;
        }

        IP = ip.getText().toString();
        MASK = mask.getText().toString();
        GATE_WAY = gate.getText().toString();
        DNS = dns.getText().toString();
        if (MQTT.isChecked()) {
            mqtt_enb = 1;
        } else {
            mqtt_enb = 0;
        }
        adress_mqtt = brokermqt.getText().toString();
        port_mqtt = portmqt.getText().toString();
        user_mqtt = usermqt.getText().toString();
        pass_mqtt = passmqt.getText().toString();
        if (sous_topic.getSelectedItemPosition() == 0) soustopic_mqtt = "all";
        if (sous_topic.getSelectedItemPosition() == 1) soustopic_mqtt = "temp";
        if (sous_topic.getSelectedItemPosition() == 2) soustopic_mqtt = "humid";
        if (sous_topic.getSelectedItemPosition() == 3) soustopic_mqtt = "lux";
        if (sous_topic.getSelectedItemPosition() == 4) soustopic_mqtt = "co2";
        if (sous_topic.getSelectedItemPosition() == 5) soustopic_mqtt = "tvoc";
        mqtt_time_sec = time_mqtt.getSelectedItemPosition() + 1;
        topic_mqtt = topicmqt.getText().toString();
        if (udp_enb.isChecked()) {
            UDP_enb = 1;
        } else {
            UDP_enb = 0;
        }
        if (udp_4or6.isChecked()) {
            UDP_idp4_idp6 = 1;
        } else {
            UDP_idp4_idp6 = 0;
        }
        UDP_server = udp_server.getText().toString();
        UDP_port = Integer.valueOf(udp_port.getText().toString());
    }

    public void read_avancee() {
        pIr.setText(String.valueOf(pir));

        if (tz == (-12)) a.setSelection(0);
        if (tz == (-11)) a.setSelection(1);
        if (tz == (-10)) a.setSelection(2);
        if (tz == (-9)) a.setSelection(3);
        if (tz == (-8)) a.setSelection(4);
        if (tz == (-7)) a.setSelection(5);
        if (tz == (-6)) a.setSelection(6);
        if (tz == (-5)) a.setSelection(7);
        if (tz == (-4)) a.setSelection(8);
        if (tz == (-3)) a.setSelection(9);
        if (tz == (-2)) a.setSelection(10);
        if (tz == (-1)) a.setSelection(11);
        if (tz == 0) a.setSelection(12);
        if (tz == 1) a.setSelection(13);
        if (tz == 2) a.setSelection(14);
        if (tz == 3) a.setSelection(15);
        if (tz == 4) a.setSelection(16);
        if (tz == 5) a.setSelection(17);
        if (tz == 6) a.setSelection(18);
        if (tz == 7) a.setSelection(19);
        if (tz == 8) a.setSelection(20);
        if (tz == 9) a.setSelection(21);
        if (tz == 10) a.setSelection(22);
        if (tz == 11) a.setSelection(23);
        if (tz == 12) a.setSelection(24);

        if (Summer_time == 0) {
            SUMMER.setChecked(false);
        } else {
            SUMMER.setChecked(true);
        }
        if (ftp_enb == 0) {
            FTP.setChecked(false);
        } else {
            FTP.setChecked(true);
        }
        servftp.setText(adress_ftp);
        portftp.setText(port_ftp);
        userftp.setText(user_ftp);
        passftp.setText(pass_ftp);
        Client_id_ftp.setText(client_id_ftp);
        if (ftp_now_or_later == 0) {
            ftp_bool_sending.setChecked(false);
        } else {
            ftp_bool_sending.setChecked(true);
        }
        ftp_time_heure.setSelection(ftp_time_send_heure);
        ftp_time_minute.setSelection(ftp_time_send_minute);
        ftp_duration.setSelection(ftp_timeout);

        if (ip_enb == 0) {
            IP_enb.setChecked(false);
        } else {
            IP_enb.setChecked(true);
        }
        ip.setText(IP);
        mask.setText(MASK);
        gate.setText(GATE_WAY);
        dns.setText(DNS);

        if (mqtt_enb == 0) {
            MQTT.setChecked(false);
        } else {
            MQTT.setChecked(true);
        }
        brokermqt.setText(adress_mqtt);
        portmqt.setText(port_mqtt);
        usermqt.setText(user_mqtt);
        passmqt.setText(pass_mqtt);
        if (soustopic_mqtt.contains("all")) {
            sous_topic.setSelection(0);
        }
        if (soustopic_mqtt.contains("temp")) {
            sous_topic.setSelection(1);
        }
        if (soustopic_mqtt.contains("humid")) {
            sous_topic.setSelection(2);
        }
        if (soustopic_mqtt.contains("lux")) {
            sous_topic.setSelection(3);
        }
        if (soustopic_mqtt.contains("co2")) {
            sous_topic.setSelection(4);
        }
        if (soustopic_mqtt.contains("tvoc")) {
            sous_topic.setSelection(5);
        }
        time_mqtt.setSelection(mqtt_time_sec - 1);
        topicmqt.setText(topic_mqtt);
        if (UDP_enb == 0) {
            udp_enb.setChecked(false);
        } else {
            udp_enb.setChecked(true);
        }
        if (UDP_idp4_idp6 == 0) {
            udp_4or6.setChecked(false);
        } else {
            udp_4or6.setChecked(true);
        }
        udp_server.setText(UDP_server);
        udp_port.setText(String.valueOf(UDP_port));
        checking_ftp_time();
        if (IP_enb.isChecked()) {
            ip.setEnabled(true);
            mask.setEnabled(true);
            gate.setEnabled(true);
            dns.setEnabled(true);
        } else {
            ip.setEnabled(false);
            mask.setEnabled(false);
            gate.setEnabled(false);
            dns.setEnabled(false);
        }
        if (udp_enb.isChecked()) {
            udp_4or6.setEnabled(true);
            udp_server.setEnabled(true);
            udp_port.setEnabled(true);
        } else {
            udp_4or6.setEnabled(false);
            udp_server.setEnabled(false);
            udp_port.setEnabled(false);
        }
        if (FTP.isChecked()) {
            servftp.setEnabled(true);
            portftp.setEnabled(true);
            userftp.setEnabled(true);
            passftp.setEnabled(true);
            ftp_bool_sending.setEnabled(true);
            ftp_time_heure.setEnabled(true);
            ftp_time_minute.setEnabled(true);
            ftp_duration.setEnabled(true);
        } else {
            servftp.setEnabled(false);
            portftp.setEnabled(false);
            userftp.setEnabled(false);
            passftp.setEnabled(false);
            ftp_bool_sending.setEnabled(false);
            ftp_time_heure.setEnabled(false);
            ftp_time_minute.setEnabled(false);
            ftp_duration.setEnabled(false);
        }
        if (MQTT.isChecked()) {
            brokermqt.setEnabled(true);
            portmqt.setEnabled(true);
            usermqt.setEnabled(true);
            passmqt.setEnabled(true);
            topicmqt.setEnabled(true);
            sous_topic.setEnabled(true);
            time_mqtt.setEnabled(true);
        } else {
            brokermqt.setEnabled(false);
            portmqt.setEnabled(false);
            usermqt.setEnabled(false);
            passmqt.setEnabled(false);
            topicmqt.setEnabled(false);
            sous_topic.setEnabled(false);
            time_mqtt.setEnabled(false);
        }
    }

    public Switch myswitch_access;

    public void MAN_AUTO() {
        myswitch_access = menuItem.getActionView().findViewById(R.id.manorauto);
        if (state == 0) {
            myswitch_access.setChecked(false);
        } else {
            myswitch_access.setChecked(true);
        }
        myswitch_access.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
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
            myswitch_access.setClickable(true);
        } else {
            myswitch_access.setClickable(false);
        }
    }

    @Override
    public void onBackPressed() {
        write_config();
        final AlertDialog.Builder builder = new AlertDialog.Builder(serveur_access.this);
        builder.setMessage("Pour appliquer les modifications votre HuBBox va redémarrer. Redémarrer maintenant ?")
                .setCancelable(false)
                .setTitle("Redémarrage de la carte :")
                .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, final int id) {
                        String system1 = "{\"system\":1}";
                        if (mConnected) {
                            Boolean checks = false;

                            do {
                                checks = writecharacteristic(3, 1, system1);

                            }
                            while (!checks);
                        }
                        Intent intent1 = new Intent(serveur_access.this, DeviceScanActivity.class);
                        intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        startActivity(intent1);
                    }
                })
                .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, final int id) {
                        write_access = false;
                        if (state == 0) {
                            myswitch.setChecked(false);
                        } else {
                            myswitch.setChecked(true);
                        }
                        write_access = true;
                        unregisterReceiver(mGattUpdateReceiver);
                        back();
                        dialog.cancel();
                    }
                });
        final AlertDialog alert = builder.create();
        alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
        alert.show();

    }

    public void back() {
        super.onBackPressed();
    }

    public void checking_ftp_time() {
        if (ftp_bool_sending.isChecked()) {
            ftp_time_heure.setEnabled(false);
            ftp_time_minute.setEnabled(false);
            ftp_duration.setEnabled(true);
        } else {
            ftp_time_heure.setEnabled(true);
            ftp_time_minute.setEnabled(true);
            ftp_duration.setEnabled(false);
        }
    }

    public void detect_time_zone() {
        if (x.equals("GMT-12:00")) a.setSelection(0);
        if (x.equals("GMT-11:00")) a.setSelection(1);
        if (x.equals("GMT-10:00")) a.setSelection(2);
        if (x.equals("GMT-09:00")) a.setSelection(3);
        if (x.equals("GMT-08:00")) a.setSelection(4);
        if (x.equals("GMT-07:00")) a.setSelection(5);
        if (x.equals("GMT-06:00")) a.setSelection(6);
        if (x.equals("GMT-05:00")) a.setSelection(7);
        if (x.equals("GMT-04:00")) a.setSelection(8);
        if (x.equals("GMT-03:00")) a.setSelection(9);
        if (x.equals("GMT-02:00")) a.setSelection(10);
        if (x.equals("GMT-01:00")) a.setSelection(11);
        if (x.equals("GMT+00:00")) a.setSelection(12);
        if (x.equals("GMT+01:00")) a.setSelection(13);
        if (x.equals("GMT+02:00")) a.setSelection(14);
        if (x.equals("GMT+03:00")) a.setSelection(15);
        if (x.equals("GMT+04:00")) a.setSelection(16);
        if (x.equals("GMT+05:00")) a.setSelection(17);
        if (x.equals("GMT+06:00")) a.setSelection(18);
        if (x.equals("GMT+07:00")) a.setSelection(19);
        if (x.equals("GMT+08:00")) a.setSelection(20);
        if (x.equals("GMT+09:00")) a.setSelection(21);
        if (x.equals("GMT+10:00")) a.setSelection(22);
        if (x.equals("GMT+11:00")) a.setSelection(23);
        if (x.equals("GMT+12:00")) a.setSelection(24);
        TimeZone timeZone = TimeZone.getDefault();
        boolean usedaylight = false;
        boolean observedaylight = false;
        if (timeZone.useDaylightTime()) {
            usedaylight = true;
        }
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (timeZone.observesDaylightTime()) {
                observedaylight = true;
            }
        } else {
            observedaylight = usedaylight;
        }
        if (observedaylight) {
            SUMMER.setChecked(true);
        } else {
            SUMMER.setChecked(false);
        }

    }

    public void time_zone() {
        int j = -12;
        for (int i = 0; i < 25; i++) {
            if (j > 0) {
                arraySpinnertimezone[i] = "GMT +" + j + ":00";
            } else {
                arraySpinnertimezone[i] = "GMT " + j + ":00";
            }
            j = j + 1;
        }
    }

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
    public MenuItem menuItem;

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

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.menu_disconnect:
                mBluetoothLeService.disconnect();
                Intent i = new Intent(serveur_access.this, DeviceScanActivity.class);
                i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(i);
                return true;
            case android.R.id.home:
                onBackPressed();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter());
        if (mBluetoothLeService != null) {
            final boolean result = mBluetoothLeService.connect(mDeviceAddress);
            Log.d("myApp", "Connect request result=" + result);
        }
    }

    /*@Override
    protected void onPause() {
        super.onPause();
        unregisterReceiver(mGattUpdateReceiver);
    }*/

    private final BroadcastReceiver mGattUpdateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String action = intent.getAction();
            if (BluetoothLeService.ACTION_GATT_CONNECTED.equals(action)) {
                mConnected = true;
                invalidateOptionsMenu();
            } else if (BluetoothLeService.ACTION_GATT_DISCONNECTED.equals(action)) {
                mConnected = false;
                invalidateOptionsMenu();
            }
        }
    };

    private static IntentFilter makeGattUpdateIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_CONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_DISCONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED);
        intentFilter.addAction(BluetoothLeService.ACTION_DATA_AVAILABLE);
        return intentFilter;
    }
}
