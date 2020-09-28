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
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.Toast;
import android.widget.ToggleButton;

import java.util.ArrayList;

import static deliled.Applications.android.Maestro.DeviceScanActivity.ACCESS;
import static deliled.Applications.android.Maestro.MainActivity.Scene_state;
import static deliled.Applications.android.Maestro.MainActivity.Zone_1;
import static deliled.Applications.android.Maestro.MainActivity.Zone_2;
import static deliled.Applications.android.Maestro.MainActivity.Zone_2_veille;
import static deliled.Applications.android.Maestro.MainActivity.Zone_3;
import static deliled.Applications.android.Maestro.MainActivity.Zone_4;
import static deliled.Applications.android.Maestro.MainActivity.Zone_veille;
import static deliled.Applications.android.Maestro.MainActivity.bleReadWrite;
import static deliled.Applications.android.Maestro.MainActivity.days;
import static deliled.Applications.android.Maestro.MainActivity.days_2;
import static deliled.Applications.android.Maestro.MainActivity.dec_2_enb;
import static deliled.Applications.android.Maestro.MainActivity.dec_enb;
import static deliled.Applications.android.Maestro.MainActivity.detec_denc_m;
import static deliled.Applications.android.Maestro.MainActivity.enc_2_days;
import static deliled.Applications.android.Maestro.MainActivity.enc_2_zones;
import static deliled.Applications.android.Maestro.MainActivity.enc_days;
import static deliled.Applications.android.Maestro.MainActivity.enc_zones;
import static deliled.Applications.android.Maestro.MainActivity.heure_denc_2_h;
import static deliled.Applications.android.Maestro.MainActivity.heure_denc_2_m;
import static deliled.Applications.android.Maestro.MainActivity.heure_denc_h;
import static deliled.Applications.android.Maestro.MainActivity.heure_denc_m;
import static deliled.Applications.android.Maestro.MainActivity.heure_enc_2_time_h;
import static deliled.Applications.android.Maestro.MainActivity.heure_enc_2_time_m;
import static deliled.Applications.android.Maestro.MainActivity.heure_enc_time_h;
import static deliled.Applications.android.Maestro.MainActivity.heure_enc_time_m;
import static deliled.Applications.android.Maestro.MainActivity.mConnected;
import static deliled.Applications.android.Maestro.MainActivity.mDeviceAddress;
import static deliled.Applications.android.Maestro.MainActivity.mGattCharacteristics;
import static deliled.Applications.android.Maestro.MainActivity.pir_days;
import static deliled.Applications.android.Maestro.MainActivity.pir_enc;
import static deliled.Applications.android.Maestro.MainActivity.pir_zones;
import static deliled.Applications.android.Maestro.MainActivity.state;
import static deliled.Applications.android.Maestro.MainActivity.veille_enb;
import static deliled.Applications.android.Maestro.MainActivity.write_profils;
import static deliled.Applications.android.Maestro.MainActivity.myswitch;
import static deliled.Applications.android.Maestro.ajustement_luminosite.isHexNumber;

public class veille_detections extends Activity {
    Spinner veille_spinner;
    ToggleButton veille_zone1_enc,veille_zone2_enc,veille_zone3_enc,veille_zone4_enc,veille_010v_enc;
    ToggleButton veille_zone1_dec,veille_zone2_dec,veille_zone3_dec,veille_zone4_dec,veille_010v_dec;
    ToggleButton veille_zone1_2_enc,veille_zone2_2_enc,veille_zone3_2_enc,veille_zone4_2_enc,veille_010v_2_enc;
    ToggleButton veille_zone1_2_dec,veille_zone2_2_dec,veille_zone3_2_dec,veille_zone4_2_dec,veille_010v_2_dec;
    ToggleButton veille_zone1_pir,veille_zone2_pir,veille_zone3_pir,veille_zone4_pir,veille_010v_pir;
    Spinner debut_heure,debut_minute,fin_heure,fin_minute,debut_heure_2,debut_minute_2,fin_heure_2,fin_minute_2;
    Switch enc_enb,dec_enc,pir_enb,enc_2_enb,dec_2_enc;
    ToggleButton Lundi_enc,Mardi_enc,Mercredi_enc,Jeudi_enc,Vendredi_enc,Samedi_enc,Dimanche_enc;
    ToggleButton Lundi_dec,Mardi_dec,Mercredi_dec,Jeudi_dec,Vendredi_dec,Samedi_dec,Dimanche_dec;
    ToggleButton Lundi_2_enc,Mardi_2_enc,Mercredi_2_enc,Jeudi_2_enc,Vendredi_2_enc,Samedi_2_enc,Dimanche_2_enc;
    ToggleButton Lundi_2_dec,Mardi_2_dec,Mercredi_2_dec,Jeudi_2_dec,Vendredi_2_dec,Samedi_2_dec,Dimanche_2_dec;
    ToggleButton Lundi_pir,Mardi_pir,Mercredi_pir,Jeudi_pir,Vendredi_pir,Samedi_pir,Dimanche_pir;
    public BluetoothLeService mBluetoothLeService;
    public BluetoothGattCharacteristic mNotifyCharacteristic;
    public ArrayList<ArrayList<BluetoothGattCharacteristic>> mGattveileeCharacteristics = new ArrayList<>();
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.veille_detection);
        getActionBar().setIcon(R.drawable.lumiair);
        mGattveileeCharacteristics=mGattCharacteristics;
        getActionBar().setDisplayHomeAsUpEnabled(true);
        Intent gattServiceIntent = new Intent(this, BluetoothLeService.class);
        bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE);
        getActionBar().setTitle("Allumage/Extinction");
        enc_enb=findViewById(R.id.switch_encloche);
        dec_enc=findViewById(R.id.switch_decloche);
        enc_2_enb=findViewById(R.id.switch_encloche_2);
        dec_2_enc=findViewById(R.id.switch_decloche_2);
        pir_enb=findViewById(R.id.switch_pir);
        veille_spinner=findViewById(R.id.detection_spinner);
        veille_zone1_enc=findViewById(R.id.detect_veille_zone1_enc);
        veille_zone2_enc=findViewById(R.id.detect_veille_zone2_enc);
        veille_zone3_enc=findViewById(R.id.detect_veille_zone3_enc);
        veille_zone4_enc=findViewById(R.id.detect_veille_zone4_enc);
        veille_010v_enc=findViewById(R.id.detect_veille_volt_zone_enc);
        veille_zone1_dec=findViewById(R.id.detect_veille_zone1);
        veille_zone2_dec=findViewById(R.id.detect_veille_zone2);
        veille_zone3_dec=findViewById(R.id.detect_veille_zone3);
        veille_zone4_dec=findViewById(R.id.detect_veille_zone4);
        veille_010v_dec=findViewById(R.id.detect_veille_volt_zone);
        veille_zone1_2_enc=findViewById(R.id.detect_veille_zone1_2_enc);
        veille_zone2_2_enc=findViewById(R.id.detect_veille_zone2_2_enc);
        veille_zone3_2_enc=findViewById(R.id.detect_veille_zone3_2_enc);
        veille_zone4_2_enc=findViewById(R.id.detect_veille_zone4_2_enc);
        veille_010v_2_enc=findViewById(R.id.detect_veille_volt_zone_2_enc);
        veille_zone1_2_dec=findViewById(R.id.detect_veille_2_zone1);
        veille_zone2_2_dec=findViewById(R.id.detect_veille_2_zone2);
        veille_zone3_2_dec=findViewById(R.id.detect_veille_2_zone3);
        veille_zone4_2_dec=findViewById(R.id.detect_veille_2_zone4);
        veille_010v_2_dec=findViewById(R.id.detect_veille_volt_2_zone);
        veille_zone1_pir=findViewById(R.id.detect_pir_zone1);
        veille_zone2_pir=findViewById(R.id.detect_pir_zone2);
        veille_zone3_pir=findViewById(R.id.detect_pir_zone3);
        veille_zone4_pir=findViewById(R.id.detect_pir_zone4);
        veille_010v_pir=findViewById(R.id.detect_pir_volt_zone);
        Lundi_enc=findViewById(R.id.lundi_enc);
        Mardi_enc=findViewById(R.id.mardi_enc);
        Mercredi_enc=findViewById(R.id.mercredi_enc);
        Jeudi_enc=findViewById(R.id.jeudi_enc);
        Vendredi_enc=findViewById(R.id.vendredi_enc);
        Samedi_enc=findViewById(R.id.samedi_enc);
        Dimanche_enc=findViewById(R.id.dimanche_enc);
        Lundi_dec=findViewById(R.id.lundi);
        Mardi_dec=findViewById(R.id.mardi);
        Mercredi_dec=findViewById(R.id.mercredi);
        Jeudi_dec=findViewById(R.id.jeudi);
        Vendredi_dec=findViewById(R.id.vendredi);
        Samedi_dec=findViewById(R.id.samedi);
        Dimanche_dec=findViewById(R.id.dimanche);
        Lundi_2_enc=findViewById(R.id.lundi_2_enc);
        Mardi_2_enc=findViewById(R.id.mardi_2_enc);
        Mercredi_2_enc=findViewById(R.id.mercredi_2_enc);
        Jeudi_2_enc=findViewById(R.id.jeudi_2_enc);
        Vendredi_2_enc=findViewById(R.id.vendredi_2_enc);
        Samedi_2_enc=findViewById(R.id.samedi_2_enc);
        Dimanche_2_enc=findViewById(R.id.dimanche_2_enc);
        Lundi_2_dec=findViewById(R.id.lundi_2);
        Mardi_2_dec=findViewById(R.id.mardi_2);
        Mercredi_2_dec=findViewById(R.id.mercredi_2);
        Jeudi_2_dec=findViewById(R.id.jeudi_2);
        Vendredi_2_dec=findViewById(R.id.vendredi_2);
        Samedi_2_dec=findViewById(R.id.samedi_2);
        Dimanche_2_dec=findViewById(R.id.dimanche_2);
        Lundi_pir=findViewById(R.id.lundi_pir);
        Mardi_pir=findViewById(R.id.mardi_pir);
        Mercredi_pir=findViewById(R.id.mercredi_pir);
        Jeudi_pir=findViewById(R.id.jeudi_pir);
        Vendredi_pir=findViewById(R.id.vendredi_pir);
        Samedi_pir=findViewById(R.id.samedi_pir);
        Dimanche_pir=findViewById(R.id.dimanche_pir);
        debut_heure=findViewById(R.id.spinnermindebut);
        debut_minute=findViewById(R.id.spinnerheuredebut);
        fin_heure=findViewById(R.id.spinnerminfin);
        fin_minute=findViewById(R.id.spinnerheurefin);
        debut_heure_2=findViewById(R.id.spinnermindebut_2);
        debut_minute_2=findViewById(R.id.spinnerheuredebut_2);
        fin_heure_2=findViewById(R.id.spinnerminfin_2);
        fin_minute_2=findViewById(R.id.spinnerheurefin_2);
        ArrayAdapter <String> adapter = new ArrayAdapter<>(this, R.layout.spinner_item,getResources().getStringArray(R.array.heure));
        adapter.setDropDownViewResource(R.layout.drop_list_spinner);
        debut_heure.setAdapter(adapter);
        debut_heure_2.setAdapter(adapter);
        ArrayAdapter <String> adapter1 = new ArrayAdapter<>(this, R.layout.spinner_item,getResources().getStringArray(R.array.minute));
        adapter1.setDropDownViewResource(R.layout.drop_list_spinner);
        debut_minute.setAdapter(adapter1);
        fin_heure.setAdapter(adapter);
        fin_minute.setAdapter(adapter1);
        veille_spinner.setAdapter(adapter1);
        debut_minute_2.setAdapter(adapter1);
        fin_heure_2.setAdapter(adapter);
        fin_minute_2.setAdapter(adapter1);
        enc_enb.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(isChecked)
                {
                    veille_zone1_enc.setEnabled(true);veille_zone2_enc.setEnabled(true);veille_zone3_enc.setEnabled(true);veille_zone4_enc.setEnabled(true);veille_010v_enc.setEnabled(true);
                    Lundi_enc.setEnabled(true);Mardi_enc.setEnabled(true);Mercredi_enc.setEnabled(true);Jeudi_enc.setEnabled(true);Vendredi_enc.setEnabled(true);Samedi_enc.setEnabled(true);Dimanche_enc.setEnabled(true);
                    debut_heure.setEnabled(true);debut_minute.setEnabled(true);
                }
                else
                {
                    veille_zone1_enc.setEnabled(false);veille_zone2_enc.setEnabled(false);veille_zone3_enc.setEnabled(false);veille_zone4_enc.setEnabled(false);veille_010v_enc.setEnabled(false);
                    Lundi_enc.setEnabled(false);Mardi_enc.setEnabled(false);Mercredi_enc.setEnabled(false);Jeudi_enc.setEnabled(false);Vendredi_enc.setEnabled(false);Samedi_enc.setEnabled(false);Dimanche_enc.setEnabled(false);
                    debut_heure.setEnabled(false);debut_minute.setEnabled(false);
                }
            }
        });
        enc_2_enb.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(isChecked)
                {
                    veille_zone1_2_enc.setEnabled(true);veille_zone2_2_enc.setEnabled(true);veille_zone3_2_enc.setEnabled(true);veille_zone4_2_enc.setEnabled(true);veille_010v_2_enc.setEnabled(true);
                    Lundi_2_enc.setEnabled(true);Mardi_2_enc.setEnabled(true);Mercredi_2_enc.setEnabled(true);Jeudi_2_enc.setEnabled(true);Vendredi_2_enc.setEnabled(true);Samedi_2_enc.setEnabled(true);Dimanche_2_enc.setEnabled(true);
                    debut_heure_2.setEnabled(true);debut_minute_2.setEnabled(true);
                }
                else
                {
                    veille_zone1_2_enc.setEnabled(false);veille_zone2_2_enc.setEnabled(false);veille_zone3_2_enc.setEnabled(false);veille_zone4_2_enc.setEnabled(false);veille_010v_2_enc.setEnabled(false);
                    Lundi_2_enc.setEnabled(false);Mardi_2_enc.setEnabled(false);Mercredi_2_enc.setEnabled(false);Jeudi_2_enc.setEnabled(false);Vendredi_2_enc.setEnabled(false);Samedi_2_enc.setEnabled(false);Dimanche_2_enc.setEnabled(false);
                    debut_heure_2.setEnabled(false);debut_minute_2.setEnabled(false);
                }
            }
        });
        dec_enc.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(isChecked)
                {
                    veille_zone1_dec.setEnabled(true);veille_zone2_dec.setEnabled(true);veille_zone3_dec.setEnabled(true);veille_zone4_dec.setEnabled(true);veille_010v_dec.setEnabled(true);
                    Lundi_dec.setEnabled(true);Mardi_dec.setEnabled(true);Mercredi_dec.setEnabled(true);Jeudi_dec.setEnabled(true);Vendredi_dec.setEnabled(true);Samedi_dec.setEnabled(true);Dimanche_dec.setEnabled(true);
                    fin_heure.setEnabled(true);fin_minute.setEnabled(true);
                }
                else
                {
                    veille_zone1_dec.setEnabled(false);veille_zone2_dec.setEnabled(false);veille_zone3_dec.setEnabled(false);veille_zone4_dec.setEnabled(false);veille_010v_dec.setEnabled(false);
                    Lundi_dec.setEnabled(false);Mardi_dec.setEnabled(false);Mercredi_dec.setEnabled(false);Jeudi_dec.setEnabled(false);Vendredi_dec.setEnabled(false);Samedi_dec.setEnabled(false);Dimanche_dec.setEnabled(false);
                    fin_heure.setEnabled(false);fin_minute.setEnabled(false);
                }
            }
        });
        dec_2_enc.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(isChecked)
                {
                    veille_zone1_2_dec.setEnabled(true);veille_zone2_2_dec.setEnabled(true);veille_zone3_2_dec.setEnabled(true);veille_zone4_2_dec.setEnabled(true);veille_010v_2_dec.setEnabled(true);
                    Lundi_2_dec.setEnabled(true);Mardi_2_dec.setEnabled(true);Mercredi_2_dec.setEnabled(true);Jeudi_2_dec.setEnabled(true);Vendredi_2_dec.setEnabled(true);Samedi_2_dec.setEnabled(true);Dimanche_2_dec.setEnabled(true);
                    fin_heure_2.setEnabled(true);fin_minute_2.setEnabled(true);
                }
                else
                {
                    veille_zone1_2_dec.setEnabled(false);veille_zone2_2_dec.setEnabled(false);veille_zone3_2_dec.setEnabled(false);veille_zone4_2_dec.setEnabled(false);veille_010v_2_dec.setEnabled(false);
                    Lundi_2_dec.setEnabled(false);Mardi_2_dec.setEnabled(false);Mercredi_2_dec.setEnabled(false);Jeudi_2_dec.setEnabled(false);Vendredi_2_dec.setEnabled(false);Samedi_2_dec.setEnabled(false);Dimanche_2_dec.setEnabled(false);
                    fin_heure_2.setEnabled(false);fin_minute_2.setEnabled(false);
                }
            }
        });
        pir_enb.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(isChecked)
                {
                    veille_zone1_pir.setEnabled(true);veille_zone2_pir.setEnabled(true);veille_zone3_pir.setEnabled(true);veille_zone4_pir.setEnabled(true);veille_010v_pir.setEnabled(true);
                    Lundi_pir.setEnabled(true);Mardi_pir.setEnabled(true);Mercredi_pir.setEnabled(true);Jeudi_pir.setEnabled(true);Vendredi_pir.setEnabled(true);Samedi_pir.setEnabled(true);Dimanche_pir.setEnabled(true);
                    veille_spinner.setEnabled(true);
                }
                else
                {
                    veille_zone1_pir.setEnabled(false);veille_zone2_pir.setEnabled(false);veille_zone3_pir.setEnabled(false);veille_zone4_pir.setEnabled(false);veille_010v_pir.setEnabled(false);
                    Lundi_pir.setEnabled(false);Mardi_pir.setEnabled(false);Mercredi_pir.setEnabled(false);Jeudi_pir.setEnabled(false);Vendredi_pir.setEnabled(false);Samedi_pir.setEnabled(false);Dimanche_pir.setEnabled(false);
                    veille_spinner.setEnabled(false);
                }
            }
        });
        read_profile();
    }
    public void read_profile() {
        if(MainActivity.enc_enb==1)
        {
            enc_enb.setChecked(true);
        }
        else
        {
            enc_enb.setChecked(false);
        }
        if(MainActivity.enc_2_enb==1)
        {
            enc_2_enb.setChecked(true);
        }
        else
        {
            enc_2_enb.setChecked(false);
        }
        if(dec_enb==1)
        {
            dec_enc.setChecked(true);
        }
        else
        {
            dec_enc.setChecked(false);
        }
        if(dec_2_enb==1)
        {
            dec_2_enc.setChecked(true);
        }
        else
        {
            dec_2_enc.setChecked(false);
        }
        if(pir_enc==1)
        {
            pir_enb.setChecked(true);
        }
        else {
            pir_enb.setChecked(false);
        }
        if(!isHexNumber(enc_days))
        {
            enc_days="0";
        }
        int zone_enc = Integer.parseInt(enc_days,16);
        int z_enc1 = zone_enc/64;
        int z_enc2 = zone_enc%64/32;
        int z_enc3 = zone_enc%32/16;
        int z_enc4 = zone_enc%16/8;
        int z_enc5 = zone_enc%8/4;
        int z_enc6 = zone_enc%4/2;
        int z_enc7 = zone_enc%2;
        Lundi_enc.setTextColor(getResources().getColor(R.color.White));
        Mardi_enc.setTextColor(getResources().getColor(R.color.White));
        Mercredi_enc.setTextColor(getResources().getColor(R.color.White));
        Jeudi_enc.setTextColor(getResources().getColor(R.color.White));
        Vendredi_enc.setTextColor(getResources().getColor(R.color.White));
        Samedi_enc.setTextColor(getResources().getColor(R.color.White));
        Dimanche_enc.setTextColor(getResources().getColor(R.color.White));
        if (z_enc1==0){Lundi_enc.setChecked(false);}else{Lundi_enc.setChecked(true);}
        if (z_enc2==0){Mardi_enc.setChecked(false);}else{Mardi_enc.setChecked(true);}
        if (z_enc3==0){Mercredi_enc.setChecked(false);}else{Mercredi_enc.setChecked(true);}
        if (z_enc4==0){Jeudi_enc.setChecked(false);}else{Jeudi_enc.setChecked(true);}
        if (z_enc5==0){Vendredi_enc.setChecked(false);}else{Vendredi_enc.setChecked(true);}
        if (z_enc6==0){Samedi_enc.setChecked(false);}else{Samedi_enc.setChecked(true);}
        if (z_enc7==0){Dimanche_enc.setChecked(false);}else{Dimanche_enc.setChecked(true);}
        if(!isHexNumber(enc_2_days))
        {
            enc_2_days="0";
        }
        int zone_enc_2 = Integer.parseInt(enc_2_days,16);
        int z_enc1_2 = zone_enc_2/64;
        int z_enc2_2 = zone_enc_2%64/32;
        int z_enc3_2 = zone_enc_2%32/16;
        int z_enc4_2 = zone_enc_2%16/8;
        int z_enc5_2 = zone_enc_2%8/4;
        int z_enc6_2 = zone_enc_2%4/2;
        int z_enc7_2 = zone_enc_2%2;
        Lundi_2_enc.setTextColor(getResources().getColor(R.color.White));
        Mardi_2_enc.setTextColor(getResources().getColor(R.color.White));
        Mercredi_2_enc.setTextColor(getResources().getColor(R.color.White));
        Jeudi_2_enc.setTextColor(getResources().getColor(R.color.White));
        Vendredi_2_enc.setTextColor(getResources().getColor(R.color.White));
        Samedi_2_enc.setTextColor(getResources().getColor(R.color.White));
        Dimanche_2_enc.setTextColor(getResources().getColor(R.color.White));
        if (z_enc1_2==0){Lundi_2_enc.setChecked(false);}else{Lundi_2_enc.setChecked(true);}
        if (z_enc2_2==0){Mardi_2_enc.setChecked(false);}else{Mardi_2_enc.setChecked(true);}
        if (z_enc3_2==0){Mercredi_2_enc.setChecked(false);}else{Mercredi_2_enc.setChecked(true);}
        if (z_enc4_2==0){Jeudi_2_enc.setChecked(false);}else{Jeudi_2_enc.setChecked(true);}
        if (z_enc5_2==0){Vendredi_2_enc.setChecked(false);}else{Vendredi_2_enc.setChecked(true);}
        if (z_enc6_2==0){Samedi_2_enc.setChecked(false);}else{Samedi_2_enc.setChecked(true);}
        if (z_enc7_2==0){Dimanche_2_enc.setChecked(false);}else{Dimanche_2_enc.setChecked(true);}

        debut_heure.setSelection(heure_enc_time_h);
        debut_minute.setSelection(heure_enc_time_m);
        fin_heure.setSelection(heure_denc_h);
        fin_minute.setSelection(heure_denc_m);
        debut_heure_2.setSelection(heure_enc_2_time_h);
        debut_minute_2.setSelection(heure_enc_2_time_m);
        fin_heure_2.setSelection(heure_denc_2_h);
        fin_minute_2.setSelection(heure_denc_2_m);
        veille_spinner.setSelection(detec_denc_m);
        if(!isHexNumber(days))
        {
            days="0";
        }
        int zone = Integer.parseInt(days,16);
        int z1 = zone/64;
        int z2 = zone%64/32;
        int z3 = zone%32/16;
        int z4 = zone%16/8;
        int z5 = zone%8/4;
        int z6 = zone%4/2;
        int z7 = zone%2;
        Lundi_dec.setTextColor(getResources().getColor(R.color.White));
        Mardi_dec.setTextColor(getResources().getColor(R.color.White));
        Mercredi_dec.setTextColor(getResources().getColor(R.color.White));
        Jeudi_dec.setTextColor(getResources().getColor(R.color.White));
        Vendredi_dec.setTextColor(getResources().getColor(R.color.White));
        Samedi_dec.setTextColor(getResources().getColor(R.color.White));
        Dimanche_dec.setTextColor(getResources().getColor(R.color.White));
        if (z1==0){Lundi_dec.setChecked(false);}else{Lundi_dec.setChecked(true);}
        if (z2==0){Mardi_dec.setChecked(false);}else{Mardi_dec.setChecked(true);}
        if (z3==0){Mercredi_dec.setChecked(false);}else{Mercredi_dec.setChecked(true);}
        if (z4==0){Jeudi_dec.setChecked(false);}else{Jeudi_dec.setChecked(true);}
        if (z5==0){Vendredi_dec.setChecked(false);}else{Vendredi_dec.setChecked(true);}
        if (z6==0){Samedi_dec.setChecked(false);}else{Samedi_dec.setChecked(true);}
        if (z7==0){Dimanche_dec.setChecked(false);}else{Dimanche_dec.setChecked(true);}
        if(!isHexNumber(days_2))
        {
            days_2="0";
        }
        int zone_2 = Integer.parseInt(days_2,16);
        int z1_2 = zone_2/64;
        int z2_2 = zone_2%64/32;
        int z3_2 = zone_2%32/16;
        int z4_2 = zone_2%16/8;
        int z5_2 = zone_2%8/4;
        int z6_2 = zone_2%4/2;
        int z7_2 = zone_2%2;
        Lundi_2_dec.setTextColor(getResources().getColor(R.color.White));
        Mardi_2_dec.setTextColor(getResources().getColor(R.color.White));
        Mercredi_2_dec.setTextColor(getResources().getColor(R.color.White));
        Jeudi_2_dec.setTextColor(getResources().getColor(R.color.White));
        Vendredi_2_dec.setTextColor(getResources().getColor(R.color.White));
        Samedi_2_dec.setTextColor(getResources().getColor(R.color.White));
        Dimanche_2_dec.setTextColor(getResources().getColor(R.color.White));
        if (z1_2==0){Lundi_2_dec.setChecked(false);}else{Lundi_2_dec.setChecked(true);}
        if (z2_2==0){Mardi_2_dec.setChecked(false);}else{Mardi_2_dec.setChecked(true);}
        if (z3_2==0){Mercredi_2_dec.setChecked(false);}else{Mercredi_2_dec.setChecked(true);}
        if (z4_2==0){Jeudi_2_dec.setChecked(false);}else{Jeudi_2_dec.setChecked(true);}
        if (z5_2==0){Vendredi_2_dec.setChecked(false);}else{Vendredi_2_dec.setChecked(true);}
        if (z6_2==0){Samedi_2_dec.setChecked(false);}else{Samedi_2_dec.setChecked(true);}
        if (z7_2==0){Dimanche_2_dec.setChecked(false);}else{Dimanche_2_dec.setChecked(true);}
        if(!isHexNumber(pir_days))
        {
            pir_days="0";
        }
        int zone_pir = Integer.parseInt(pir_days,16);
        int z_pir1 = zone_pir/64;
        int z_pir2 = zone_pir%64/32;
        int z_pir3 = zone_pir%32/16;
        int z_pir4 = zone_pir%16/8;
        int z_pir5 = zone_pir%8/4;
        int z_pir6 = zone_pir%4/2;
        int z_pir7 = zone_pir%2;
        Lundi_pir.setTextColor(getResources().getColor(R.color.White));
        Mardi_pir.setTextColor(getResources().getColor(R.color.White));
        Mercredi_pir.setTextColor(getResources().getColor(R.color.White));
        Jeudi_pir.setTextColor(getResources().getColor(R.color.White));
        Vendredi_pir.setTextColor(getResources().getColor(R.color.White));
        Samedi_pir.setTextColor(getResources().getColor(R.color.White));
        Dimanche_pir.setTextColor(getResources().getColor(R.color.White));
        if (z_pir1==0){Lundi_pir.setChecked(false);}else{Lundi_pir.setChecked(true);}
        if (z_pir2==0){Mardi_pir.setChecked(false);}else{Mardi_pir.setChecked(true);}
        if (z_pir3==0){Mercredi_pir.setChecked(false);}else{Mercredi_pir.setChecked(true);}
        if (z_pir4==0){Jeudi_pir.setChecked(false);}else{Jeudi_pir.setChecked(true);}
        if (z_pir5==0){Vendredi_pir.setChecked(false);}else{Vendredi_pir.setChecked(true);}
        if (z_pir6==0){Samedi_pir.setChecked(false);}else{Samedi_pir.setChecked(true);}
        if (z_pir7==0){Dimanche_pir.setChecked(false);}else{Dimanche_pir.setChecked(true);}
        if(!isHexNumber(enc_zones))
        {
            enc_zones="0";
        }
        int zone_v = Integer.parseInt(enc_zones, 16);
        int z_5 = zone_v / 16;
        int z_4 = zone_v % 16 / 8;
        int z_3 = zone_v % 8 / 4;
        int z_2 = zone_v % 4 / 2;
        int z_1 = zone_v % 2;
        veille_zone1_enc.setTextColor(getResources().getColor(R.color.White));
        veille_zone2_enc.setTextColor(getResources().getColor(R.color.White));
        veille_zone3_enc.setTextColor(getResources().getColor(R.color.White));
        veille_zone4_enc.setTextColor(getResources().getColor(R.color.White));
        veille_010v_enc.setTextColor(getResources().getColor(R.color.White));
        if (z_1 == 0) {
            veille_zone1_enc.setChecked(false);
        } else {
            veille_zone1_enc.setChecked(true);
        }
        if (z_2 == 0) {
            veille_zone2_enc.setChecked(false);
        } else {
            veille_zone2_enc.setChecked(true);
        }
        if (z_3 == 0) {
            veille_zone3_enc.setChecked(false);
        } else {
            veille_zone3_enc.setChecked(true);
        }
        if (z_4 == 0) {
            veille_zone4_enc.setChecked(false);
        } else {
            veille_zone4_enc.setChecked(true);
        }
        if (z_5 == 0) {
            veille_010v_enc.setChecked(false);
        } else {
            veille_010v_enc.setChecked(true);
        }
        if(!isHexNumber(enc_2_zones))
        {
            enc_2_zones="0";
        }
        int zone_v_2 = Integer.parseInt(enc_2_zones, 16);
        int z_5_2 = zone_v_2 / 16;
        int z_4_2 = zone_v_2 % 16 / 8;
        int z_3_2 = zone_v_2 % 8 / 4;
        int z_2_2 = zone_v_2 % 4 / 2;
        int z_1_2 = zone_v_2 % 2;
        veille_zone1_2_enc.setTextColor(getResources().getColor(R.color.White));
        veille_zone2_2_enc.setTextColor(getResources().getColor(R.color.White));
        veille_zone3_2_enc.setTextColor(getResources().getColor(R.color.White));
        veille_zone4_2_enc.setTextColor(getResources().getColor(R.color.White));
        veille_010v_2_enc.setTextColor(getResources().getColor(R.color.White));
        if (z_1_2 == 0) {
            veille_zone1_2_enc.setChecked(false);
        } else {
            veille_zone1_2_enc.setChecked(true);
        }
        if (z_2_2 == 0) {
            veille_zone2_2_enc.setChecked(false);
        } else {
            veille_zone2_2_enc.setChecked(true);
        }
        if (z_3_2 == 0) {
            veille_zone3_2_enc.setChecked(false);
        } else {
            veille_zone3_2_enc.setChecked(true);
        }
        if (z_4_2 == 0) {
            veille_zone4_2_enc.setChecked(false);
        } else {
            veille_zone4_2_enc.setChecked(true);
        }
        if (z_5_2 == 0) {
            veille_010v_2_enc.setChecked(false);
        } else {
            veille_010v_2_enc.setChecked(true);
        }
        if(!isHexNumber(Zone_2_veille))
        {
            Zone_2_veille="0";
        }
        int zone_dec_2_v = Integer.parseInt(Zone_2_veille, 16);
        int z_dec_5_2 = zone_dec_2_v / 16;
        int z_dec_4_2 = zone_dec_2_v % 16 / 8;
        int z_dec_3_2 = zone_dec_2_v % 8 / 4;
        int z_dec_2_2 = zone_dec_2_v % 4 / 2;
        int z_dec_1_2 = zone_dec_2_v % 2;
        veille_zone1_2_dec.setTextColor(getResources().getColor(R.color.White));
        veille_zone2_2_dec.setTextColor(getResources().getColor(R.color.White));
        veille_zone3_2_dec.setTextColor(getResources().getColor(R.color.White));
        veille_zone4_2_dec.setTextColor(getResources().getColor(R.color.White));
        veille_010v_2_dec.setTextColor(getResources().getColor(R.color.White));
        if (z_dec_1_2 == 0) {
            veille_zone1_2_dec.setChecked(false);
        } else {
            veille_zone1_2_dec.setChecked(true);
        }
        if (z_dec_2_2 == 0) {
            veille_zone2_2_dec.setChecked(false);
        } else {
            veille_zone2_2_dec.setChecked(true);
        }
        if (z_dec_3_2 == 0) {
            veille_zone3_2_dec.setChecked(false);
        } else {
            veille_zone3_2_dec.setChecked(true);
        }
        if (z_dec_4_2 == 0) {
            veille_zone4_2_dec.setChecked(false);
        } else {
            veille_zone4_2_dec.setChecked(true);
        }
        if (z_dec_5_2 == 0) {
            veille_010v_2_dec.setChecked(false);
        } else {
            veille_010v_2_dec.setChecked(true);
        }
        if(!isHexNumber(Zone_veille))
        {
            Zone_veille="0";
        }
        int zone_dec_v = Integer.parseInt(Zone_veille, 16);
        int z_dec_5 = zone_dec_v / 16;
        int z_dec_4 = zone_dec_v % 16 / 8;
        int z_dec_3 = zone_dec_v % 8 / 4;
        int z_dec_2 = zone_dec_v % 4 / 2;
        int z_dec_1 = zone_dec_v % 2;
        veille_zone1_dec.setTextColor(getResources().getColor(R.color.White));
        veille_zone2_dec.setTextColor(getResources().getColor(R.color.White));
        veille_zone3_dec.setTextColor(getResources().getColor(R.color.White));
        veille_zone4_dec.setTextColor(getResources().getColor(R.color.White));
        veille_010v_dec.setTextColor(getResources().getColor(R.color.White));
        if (z_dec_1 == 0) {
            veille_zone1_dec.setChecked(false);
        } else {
            veille_zone1_dec.setChecked(true);
        }
        if (z_dec_2 == 0) {
            veille_zone2_dec.setChecked(false);
        } else {
            veille_zone2_dec.setChecked(true);
        }
        if (z_dec_3 == 0) {
            veille_zone3_dec.setChecked(false);
        } else {
            veille_zone3_dec.setChecked(true);
        }
        if (z_dec_4 == 0) {
            veille_zone4_dec.setChecked(false);
        } else {
            veille_zone4_dec.setChecked(true);
        }
        if (z_dec_5 == 0) {
            veille_010v_dec.setChecked(false);
        } else {
            veille_010v_dec.setChecked(true);
        }
        if(!isHexNumber(pir_zones))
        {
            pir_zones="0";
        }
        int zone_pir_v = Integer.parseInt(pir_zones, 16);
        int z_pir_5 = zone_pir_v / 16;
        int z_pir_4 = zone_pir_v % 16 / 8;
        int z_pir_3 = zone_pir_v % 8 / 4;
        int z_pir_2 = zone_pir_v % 4 / 2;
        int z_pir_1 = zone_pir_v % 2;
        veille_zone1_pir.setTextColor(getResources().getColor(R.color.White));
        veille_zone2_pir.setTextColor(getResources().getColor(R.color.White));
        veille_zone3_pir.setTextColor(getResources().getColor(R.color.White));
        veille_zone4_pir.setTextColor(getResources().getColor(R.color.White));
        veille_010v_pir.setTextColor(getResources().getColor(R.color.White));
        if (z_pir_1 == 0) {
            veille_zone1_pir.setChecked(false);
        } else {
            veille_zone1_pir.setChecked(true);
        }
        if (z_pir_2 == 0) {
            veille_zone2_pir.setChecked(false);
        } else {
            veille_zone2_pir.setChecked(true);
        }
        if (z_pir_3 == 0) {
            veille_zone3_pir.setChecked(false);
        } else {
            veille_zone3_pir.setChecked(true);
        }
        if (z_pir_4 == 0) {
            veille_zone4_pir.setChecked(false);
        } else {
            veille_zone4_pir.setChecked(true);
        }
        if (z_pir_5 == 0) {
            veille_010v_pir.setChecked(false);
        } else {
            veille_010v_pir.setChecked(true);
        }
        veille_zone1_enc.setText(Zone_1);veille_zone1_enc.setTextOn(Zone_1);veille_zone1_enc.setTextOff(Zone_1);
        veille_zone2_enc.setText(Zone_2);veille_zone2_enc.setTextOn(Zone_2);veille_zone2_enc.setTextOff(Zone_2);
        veille_zone3_enc.setText(Zone_3);veille_zone3_enc.setTextOn(Zone_3);veille_zone3_enc.setTextOff(Zone_3);
        veille_zone4_enc.setText(Zone_4);veille_zone4_enc.setTextOn(Zone_4);veille_zone4_enc.setTextOff(Zone_4);
        veille_zone1_dec.setText(Zone_1);veille_zone1_dec.setTextOn(Zone_1);veille_zone1_dec.setTextOff(Zone_1);
        veille_zone2_dec.setText(Zone_2);veille_zone2_dec.setTextOn(Zone_2);veille_zone2_dec.setTextOff(Zone_2);
        veille_zone3_dec.setText(Zone_3);veille_zone3_dec.setTextOn(Zone_3);veille_zone3_dec.setTextOff(Zone_3);
        veille_zone4_dec.setText(Zone_4);veille_zone4_dec.setTextOn(Zone_4);veille_zone4_dec.setTextOff(Zone_4);
        veille_zone1_2_enc.setText(Zone_1);veille_zone1_2_enc.setTextOn(Zone_1);veille_zone1_2_enc.setTextOff(Zone_1);
        veille_zone2_2_enc.setText(Zone_2);veille_zone2_2_enc.setTextOn(Zone_2);veille_zone2_2_enc.setTextOff(Zone_2);
        veille_zone3_2_enc.setText(Zone_3);veille_zone3_2_enc.setTextOn(Zone_3);veille_zone3_2_enc.setTextOff(Zone_3);
        veille_zone4_2_enc.setText(Zone_4);veille_zone4_2_enc.setTextOn(Zone_4);veille_zone4_2_enc.setTextOff(Zone_4);
        veille_zone1_2_dec.setText(Zone_1);veille_zone1_2_dec.setTextOn(Zone_1);veille_zone1_2_dec.setTextOff(Zone_1);
        veille_zone2_2_dec.setText(Zone_2);veille_zone2_2_dec.setTextOn(Zone_2);veille_zone2_2_dec.setTextOff(Zone_2);
        veille_zone3_2_dec.setText(Zone_3);veille_zone3_2_dec.setTextOn(Zone_3);veille_zone3_2_dec.setTextOff(Zone_3);
        veille_zone4_2_dec.setText(Zone_4);veille_zone4_2_dec.setTextOn(Zone_4);veille_zone4_2_dec.setTextOff(Zone_4);
        veille_zone1_pir.setText(Zone_1);veille_zone1_pir.setTextOn(Zone_1);veille_zone1_pir.setTextOff(Zone_1);
        veille_zone2_pir.setText(Zone_2);veille_zone2_pir.setTextOn(Zone_2);veille_zone2_pir.setTextOff(Zone_2);
        veille_zone3_pir.setText(Zone_3);veille_zone3_pir.setTextOn(Zone_3);veille_zone3_pir.setTextOff(Zone_3);
        veille_zone4_pir.setText(Zone_4);veille_zone4_pir.setTextOn(Zone_4);veille_zone4_pir.setTextOff(Zone_4);
        if(enc_enb.isChecked())
        {
            veille_zone1_enc.setEnabled(true);veille_zone2_enc.setEnabled(true);veille_zone3_enc.setEnabled(true);veille_zone4_enc.setEnabled(true);veille_010v_enc.setEnabled(true);
            Lundi_enc.setEnabled(true);Mardi_enc.setEnabled(true);Mercredi_enc.setEnabled(true);Jeudi_enc.setEnabled(true);Vendredi_enc.setEnabled(true);Samedi_enc.setEnabled(true);Dimanche_enc.setEnabled(true);
            debut_heure.setEnabled(true);debut_minute.setEnabled(true);
        }
        else
        {
            veille_zone1_enc.setEnabled(false);veille_zone2_enc.setEnabled(false);veille_zone3_enc.setEnabled(false);veille_zone4_enc.setEnabled(false);veille_010v_enc.setEnabled(false);
            Lundi_enc.setEnabled(false);Mardi_enc.setEnabled(false);Mercredi_enc.setEnabled(false);Jeudi_enc.setEnabled(false);Vendredi_enc.setEnabled(false);Samedi_enc.setEnabled(false);Dimanche_enc.setEnabled(false);
            debut_heure.setEnabled(false);debut_minute.setEnabled(false);
        }
        if(enc_2_enb.isChecked())
        {
            veille_zone1_2_enc.setEnabled(true);veille_zone2_2_enc.setEnabled(true);veille_zone3_2_enc.setEnabled(true);veille_zone4_2_enc.setEnabled(true);veille_010v_2_enc.setEnabled(true);
            Lundi_2_enc.setEnabled(true);Mardi_2_enc.setEnabled(true);Mercredi_2_enc.setEnabled(true);Jeudi_2_enc.setEnabled(true);Vendredi_2_enc.setEnabled(true);Samedi_2_enc.setEnabled(true);Dimanche_2_enc.setEnabled(true);
            debut_heure_2.setEnabled(true);debut_minute_2.setEnabled(true);
        }
        else
        {
            veille_zone1_2_enc.setEnabled(false);veille_zone2_2_enc.setEnabled(false);veille_zone3_2_enc.setEnabled(false);veille_zone4_2_enc.setEnabled(false);veille_010v_2_enc.setEnabled(false);
            Lundi_2_enc.setEnabled(false);Mardi_2_enc.setEnabled(false);Mercredi_2_enc.setEnabled(false);Jeudi_2_enc.setEnabled(false);Vendredi_2_enc.setEnabled(false);Samedi_2_enc.setEnabled(false);Dimanche_2_enc.setEnabled(false);
            debut_heure_2.setEnabled(false);debut_minute_2.setEnabled(false);
        }
        if(dec_enc.isChecked())
        {
            veille_zone1_dec.setEnabled(true);veille_zone2_dec.setEnabled(true);veille_zone3_dec.setEnabled(true);veille_zone4_dec.setEnabled(true);veille_010v_dec.setEnabled(true);
            Lundi_dec.setEnabled(true);Mardi_dec.setEnabled(true);Mercredi_dec.setEnabled(true);Jeudi_dec.setEnabled(true);Vendredi_dec.setEnabled(true);Samedi_dec.setEnabled(true);Dimanche_dec.setEnabled(true);
            fin_heure.setEnabled(true);fin_minute.setEnabled(true);
        }
        else
        {
            veille_zone1_dec.setEnabled(false);veille_zone2_dec.setEnabled(false);veille_zone3_dec.setEnabled(false);veille_zone4_dec.setEnabled(false);veille_010v_dec.setEnabled(false);
            Lundi_dec.setEnabled(false);Mardi_dec.setEnabled(false);Mercredi_dec.setEnabled(false);Jeudi_dec.setEnabled(false);Vendredi_dec.setEnabled(false);Samedi_dec.setEnabled(false);Dimanche_dec.setEnabled(false);
            fin_heure.setEnabled(false);fin_minute.setEnabled(false);
        }
        if(dec_2_enc.isChecked())
        {
            veille_zone1_2_dec.setEnabled(true);veille_zone2_2_dec.setEnabled(true);veille_zone3_2_dec.setEnabled(true);veille_zone4_2_dec.setEnabled(true);veille_010v_2_dec.setEnabled(true);
            Lundi_2_dec.setEnabled(true);Mardi_2_dec.setEnabled(true);Mercredi_2_dec.setEnabled(true);Jeudi_dec.setEnabled(true);Vendredi_2_dec.setEnabled(true);Samedi_2_dec.setEnabled(true);Dimanche_2_dec.setEnabled(true);
            fin_heure_2.setEnabled(true);fin_minute_2.setEnabled(true);
        }
        else
        {
            veille_zone1_2_dec.setEnabled(false);veille_zone2_2_dec.setEnabled(false);veille_zone3_2_dec.setEnabled(false);veille_zone4_2_dec.setEnabled(false);veille_010v_2_dec.setEnabled(false);
            Lundi_2_dec.setEnabled(false);Mardi_2_dec.setEnabled(false);Mercredi_2_dec.setEnabled(false);Jeudi_2_dec.setEnabled(false);Vendredi_2_dec.setEnabled(false);Samedi_2_dec.setEnabled(false);Dimanche_2_dec.setEnabled(false);
            fin_heure_2.setEnabled(false);fin_minute_2.setEnabled(false);
        }
        if(pir_enb.isChecked())
        {
            veille_zone1_pir.setEnabled(true);veille_zone2_pir.setEnabled(true);veille_zone3_pir.setEnabled(true);veille_zone4_pir.setEnabled(true);veille_010v_pir.setEnabled(true);
            Lundi_pir.setEnabled(true);Mardi_pir.setEnabled(true);Mercredi_pir.setEnabled(true);Jeudi_pir.setEnabled(true);Vendredi_pir.setEnabled(true);Samedi_pir.setEnabled(true);Dimanche_pir.setEnabled(true);
            veille_spinner.setEnabled(true);
        }
        else
        {
            veille_zone1_pir.setEnabled(false);veille_zone2_pir.setEnabled(false);veille_zone3_pir.setEnabled(false);veille_zone4_pir.setEnabled(false);veille_010v_pir.setEnabled(false);
            Lundi_pir.setEnabled(false);Mardi_pir.setEnabled(false);Mercredi_pir.setEnabled(false);Jeudi_pir.setEnabled(false);Vendredi_pir.setEnabled(false);Samedi_pir.setEnabled(false);Dimanche_pir.setEnabled(false);
            veille_spinner.setEnabled(false);
        }
    }
    public void save()
    {
        if (enc_enb.isChecked()){MainActivity.enc_enb=1;}else {MainActivity.enc_enb=0;}
        if (dec_enc.isChecked()){dec_enb=1;}else {dec_enb=0;}
        if (enc_2_enb.isChecked()){MainActivity.enc_2_enb=1;}else {MainActivity.enc_2_enb=0;}
        if (dec_2_enc.isChecked()){dec_2_enb=1;}else {dec_2_enb=0;}
        if (pir_enb.isChecked()){pir_enc=1;}else {pir_enc=0;}
        heure_enc_time_h=debut_heure.getSelectedItemPosition();
        heure_enc_time_m=debut_minute.getSelectedItemPosition();
        heure_denc_h=fin_heure.getSelectedItemPosition();
        heure_denc_m=fin_minute.getSelectedItemPosition();
        heure_enc_2_time_h=debut_heure_2.getSelectedItemPosition();
        heure_enc_2_time_m=debut_minute_2.getSelectedItemPosition();
        heure_denc_2_h=fin_heure_2.getSelectedItemPosition();
        heure_denc_2_m=fin_minute_2.getSelectedItemPosition();
        int z1,z2,z3,z4,z5,z6,z7;
        if (Lundi_dec.isChecked()){z1=1;}else{z1=0;}
        if (Mardi_dec.isChecked()){z2=1;}else{z2=0;}
        if (Mercredi_dec.isChecked()){z3=1;}else{z3=0;}
        if (Jeudi_dec.isChecked()){z4=1;}else{z4=0;}
        if (Vendredi_dec.isChecked()){z5=1;}else{z5=0;}
        if (Samedi_dec.isChecked()){z6=1;}else{z6=0;}
        if (Dimanche_dec.isChecked()){z7=1;}else{z7=0;}
        days =Integer.toString((z1*64)+(z2*32)+(z3*16)+(z4*8)+(z5*4)+(z6*2)+z7, 16);
        if(days.equals("null"))days="0";
        int z1_2,z2_2,z3_2,z4_2,z5_2,z6_2,z7_2;
        if (Lundi_2_dec.isChecked()){z1_2=1;}else{z1_2=0;}
        if (Mardi_2_dec.isChecked()){z2_2=1;}else{z2_2=0;}
        if (Mercredi_2_dec.isChecked()){z3_2=1;}else{z3_2=0;}
        if (Jeudi_2_dec.isChecked()){z4_2=1;}else{z4_2=0;}
        if (Vendredi_2_dec.isChecked()){z5_2=1;}else{z5_2=0;}
        if (Samedi_2_dec.isChecked()){z6_2=1;}else{z6_2=0;}
        if (Dimanche_2_dec.isChecked()){z7_2=1;}else{z7_2=0;}
        days_2 =Integer.toString((z1_2*64)+(z2_2*32)+(z3_2*16)+(z4_2*8)+(z5_2*4)+(z6_2*2)+z7_2, 16);
        if(days_2.equals("null"))days_2="0";
        int z_enc_1,z_enc_2,z_enc_3,z_enc_4,z_enc_5,z_enc_6,z_enc_7;
        if (Lundi_enc.isChecked()){z_enc_1=1;}else{z_enc_1=0;}
        if (Mardi_enc.isChecked()){z_enc_2=1;}else{z_enc_2=0;}
        if (Mercredi_enc.isChecked()){z_enc_3=1;}else{z_enc_3=0;}
        if (Jeudi_enc.isChecked()){z_enc_4=1;}else{z_enc_4=0;}
        if (Vendredi_enc.isChecked()){z_enc_5=1;}else{z_enc_5=0;}
        if (Samedi_enc.isChecked()){z_enc_6=1;}else{z_enc_6=0;}
        if (Dimanche_enc.isChecked()){z_enc_7=1;}else{z_enc_7=0;}
        enc_days =Integer.toString((z_enc_1*64)+(z_enc_2*32)+(z_enc_3*16)+(z_enc_4*8)+(z_enc_5*4)+(z_enc_6*2)+z_enc_7, 16);
        if(enc_days.equals("null"))enc_days="0";
        int z_enc_2_1,z_enc_2_2,z_enc_2_3,z_enc_2_4,z_enc_2_5,z_enc_2_6,z_enc_2_7;
        if (Lundi_2_enc.isChecked()){z_enc_2_1=1;}else{z_enc_2_1=0;}
        if (Mardi_2_enc.isChecked()){z_enc_2_2=1;}else{z_enc_2_2=0;}
        if (Mercredi_2_enc.isChecked()){z_enc_2_3=1;}else{z_enc_2_3=0;}
        if (Jeudi_2_enc.isChecked()){z_enc_2_4=1;}else{z_enc_2_4=0;}
        if (Vendredi_2_enc.isChecked()){z_enc_2_5=1;}else{z_enc_2_5=0;}
        if (Samedi_2_enc.isChecked()){z_enc_2_6=1;}else{z_enc_2_6=0;}
        if (Dimanche_2_enc.isChecked()){z_enc_2_7=1;}else{z_enc_2_7=0;}
        enc_2_days =Integer.toString((z_enc_2_1*64)+(z_enc_2_2*32)+(z_enc_2_3*16)+(z_enc_2_4*8)+(z_enc_2_5*4)+(z_enc_2_6*2)+z_enc_2_7, 16);
        if(enc_2_days.equals("null"))enc_2_days="0";
        int d_pir_1,d_pir_2,d_pir_3,d_pir_4,d_pir_5,d_pir_6,d_pir_7;
        if (Lundi_pir.isChecked()){d_pir_1=1;}else{d_pir_1=0;}
        if (Mardi_pir.isChecked()){d_pir_2=1;}else{d_pir_2=0;}
        if (Mercredi_pir.isChecked()){d_pir_3=1;}else{d_pir_3=0;}
        if (Jeudi_pir.isChecked()){d_pir_4=1;}else{d_pir_4=0;}
        if (Vendredi_pir.isChecked()){d_pir_5=1;}else{d_pir_5=0;}
        if (Samedi_pir.isChecked()){d_pir_6=1;}else{d_pir_6=0;}
        if (Dimanche_pir.isChecked()){d_pir_7=1;}else{d_pir_7=0;}
        pir_days =Integer.toString((d_pir_1*64)+(d_pir_2*32)+(d_pir_3*16)+(d_pir_4*8)+(d_pir_5*4)+(d_pir_6*2)+d_pir_7, 16);
        if(pir_days.equals("null"))pir_days="0";
        detec_denc_m=veille_spinner.getSelectedItemPosition();
        int z_1,z_2,z_3,z_4,z_5;
        if (veille_zone1_enc.isChecked()){z_1=1;}else{z_1=0;}
        if (veille_zone2_enc.isChecked()){z_2=1;}else{z_2=0;}
        if (veille_zone3_enc.isChecked()){z_3=1;}else{z_3=0;}
        if (veille_zone4_enc.isChecked()){z_4=1;}else{z_4=0;}
        if (veille_010v_enc.isChecked()){z_5=1;}else{z_5=0;}
        enc_zones=Integer.toString((z_5*16)+(z_4*8)+(z_3*4)+(z_2*2)+z_1, 16);
        if(enc_zones.equals("null"))enc_zones="0";
        int z_2_1,z_2_2,z_2_3,z_2_4,z_2_5;
        if (veille_zone1_2_enc.isChecked()){z_2_1=1;}else{z_2_1=0;}
        if (veille_zone2_2_enc.isChecked()){z_2_2=1;}else{z_2_2=0;}
        if (veille_zone3_2_enc.isChecked()){z_2_3=1;}else{z_2_3=0;}
        if (veille_zone4_2_enc.isChecked()){z_2_4=1;}else{z_2_4=0;}
        if (veille_010v_2_enc.isChecked()){z_2_5=1;}else{z_2_5=0;}
        enc_2_zones=Integer.toString((z_2_5*16)+(z_2_4*8)+(z_2_3*4)+(z_2_2*2)+z_2_1, 16);
        if(enc_2_zones.equals("null"))enc_2_zones="0";
        int z_dec_1,z_dec_2,z_dec_3,z_dec_4,z_dec_5;
        if (veille_zone1_dec.isChecked()){z_dec_1=1;}else{z_dec_1=0;}
        if (veille_zone2_dec.isChecked()){z_dec_2=1;}else{z_dec_2=0;}
        if (veille_zone3_dec.isChecked()){z_dec_3=1;}else{z_dec_3=0;}
        if (veille_zone4_dec.isChecked()){z_dec_4=1;}else{z_dec_4=0;}
        if (veille_010v_dec.isChecked()){z_dec_5=1;}else{z_dec_5=0;}
        Zone_veille =Integer.toString((z_dec_5*16)+(z_dec_4*8)+(z_dec_3*4)+(z_dec_2*2)+z_dec_1, 16);
        if(Zone_veille.equals("null"))Zone_veille="0";
        int z_dec_2_1,z_dec_2_2,z_dec_2_3,z_dec_2_4,z_dec_2_5;
        if (veille_zone1_2_dec.isChecked()){z_dec_2_1=1;}else{z_dec_2_1=0;}
        if (veille_zone2_2_dec.isChecked()){z_dec_2_2=1;}else{z_dec_2_2=0;}
        if (veille_zone3_2_dec.isChecked()){z_dec_2_3=1;}else{z_dec_2_3=0;}
        if (veille_zone4_2_dec.isChecked()){z_dec_2_4=1;}else{z_dec_2_4=0;}
        if (veille_010v_2_dec.isChecked()){z_dec_2_5=1;}else{z_dec_2_5=0;}
        Zone_2_veille =Integer.toString((z_dec_2_5*16)+(z_dec_2_4*8)+(z_dec_2_3*4)+(z_dec_2_2*2)+z_dec_2_1, 16);
        if(Zone_2_veille.equals("null"))Zone_2_veille="0";
        int z_pir_1,z_pir_2,z_pir_3,z_pir_4,z_pir_5;
        if (veille_zone1_pir.isChecked()){z_pir_1=1;}else{z_pir_1=0;}
        if (veille_zone2_pir.isChecked()){z_pir_2=1;}else{z_pir_2=0;}
        if (veille_zone3_pir.isChecked()){z_pir_3=1;}else{z_pir_3=0;}
        if (veille_zone4_pir.isChecked()){z_pir_4=1;}else{z_pir_4=0;}
        if (veille_010v_pir.isChecked()){z_pir_5=1;}else{z_pir_5=0;}
        pir_zones =Integer.toString((z_pir_5*16)+(z_pir_4*8)+(z_pir_3*4)+(z_pir_2*2)+z_pir_1, 16);
        if(pir_zones.equals("null"))pir_zones="0";
        if (mConnected) {
            Boolean check = false;

            do {
                String enc_dec ="{\"pdata\":["+MainActivity.enc_enb+",\""+enc_days+"\",\""+enc_zones+"\","+ heure_enc_time_h+""+format(heure_enc_time_m)+ ","+MainActivity.enc_2_enb+",\""+enc_2_days+"\",\""+enc_2_zones+"\","+ heure_enc_2_time_h+""+format(heure_enc_2_time_m)+
                        ","+dec_enb+",\""+days+"\",\""+Zone_veille+"\","+ heure_denc_h+""+format(heure_denc_m)+","+dec_2_enb+",\""+days_2+"\",\""+Zone_2_veille+"\","+ heure_denc_2_h+""+format(heure_denc_2_m)+"]," +
                        "\"veille\":["+ veille_enb+","+pir_enc+ ","+ detec_denc_m+",\""+pir_days+"\",\""+pir_zones+"\"]}";
                check = writecharacteristic(3, 0, enc_dec );
                if (check) {
                    Toast.makeText(this, "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                }

            }
            while (!check);
        }

    }
    @Override
    public void onBackPressed(){
        save();
        write_profils=false;
        if (state==0)
        {
            myswitch.setChecked(false);
        }
        else
        {
            myswitch.setChecked(true);
        }
        write_profils=true;
        super.onBackPressed();
    }
    public String format (int x){
        return String.format("%02d",x);
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
    public MenuItem menuItem;
    public Switch myswitch_veille;
    public void MAN_AUTO()
    {
        myswitch_veille = menuItem.getActionView().findViewById(R.id.manorauto);
        if (state==0)
        {
            myswitch_veille.setChecked(false);
        }
        else
        {
            myswitch_veille.setChecked(true);
        }
        myswitch_veille.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(Scene_state==1)
                {
                    Toast.makeText(getApplicationContext(), "Scènes est activé ! ", Toast.LENGTH_LONG).show();
                    state = 0;
                }else {
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
        if(ACCESS)
        {
            myswitch_veille.setClickable(true);
        }else {
            myswitch_veille.setClickable(false);
        }
    }
    public boolean writecharacteristic(int i,int j, String data){
        boolean write=false;
        bleReadWrite=true;
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
        }catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        return write;
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
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch(item.getItemId()) {
            case R.id.menu_disconnect:
                Intent i=new Intent(this, DeviceScanActivity.class);
                i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(i);
                return true;
            case android.R.id.home:
                onBackPressed();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
