package deliled.Applications.android.Maestro;

import android.app.Activity;
import android.app.AlertDialog;
import android.bluetooth.BluetoothGattCharacteristic;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.IBinder;
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import java.util.ArrayList;

import static deliled.Applications.android.Maestro.DeviceScanActivity.ACCESS;
import static deliled.Applications.android.Maestro.MainActivity.CHAR_WRITE_LUMINOSITY;
import static deliled.Applications.android.Maestro.MainActivity.SERVICE_WRITE;
import static deliled.Applications.android.Maestro.MainActivity.Scene_state;
import static deliled.Applications.android.Maestro.MainActivity.Udata_als;
import static deliled.Applications.android.Maestro.MainActivity.Udata_lum_zone_010v;
import static deliled.Applications.android.Maestro.MainActivity.Udata_lum_zone_1;
import static deliled.Applications.android.Maestro.MainActivity.Udata_lum_zone_2;
import static deliled.Applications.android.Maestro.MainActivity.Udata_lum_zone_3;
import static deliled.Applications.android.Maestro.MainActivity.Udata_lum_zone_4;
import static deliled.Applications.android.Maestro.MainActivity.Zone_1;
import static deliled.Applications.android.Maestro.MainActivity.Zone_2;
import static deliled.Applications.android.Maestro.MainActivity.Zone_3;
import static deliled.Applications.android.Maestro.MainActivity.Zone_4;
import static deliled.Applications.android.Maestro.MainActivity.Zone_lum;
import static deliled.Applications.android.Maestro.MainActivity.auto_or_fixe;
import static deliled.Applications.android.Maestro.MainActivity.lum_active;
import static deliled.Applications.android.Maestro.MainActivity.auto_val;
import static deliled.Applications.android.Maestro.MainActivity.bleReadWrite;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_1_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_1_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_2_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_2_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_3_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_3_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_4_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_4_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_volt_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_end_fixe_zone_volt_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_end_h_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_end_h_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_end_m_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_end_m_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_start_h_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_start_h_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_start_m_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_start_m_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_start_zone_volt_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_fixe_start_zone_volt_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_start_fixe_zone_1_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_start_fixe_zone_1_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_start_fixe_zone_2_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_start_fixe_zone_2_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_start_fixe_zone_3_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_start_fixe_zone_3_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_start_fixe_zone_4_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_start_fixe_zone_4_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_tewenty_percent;
import static deliled.Applications.android.Maestro.MainActivity.lum_zone_010v;
import static deliled.Applications.android.Maestro.MainActivity.lum_zone_1;
import static deliled.Applications.android.Maestro.MainActivity.lum_zone_2;
import static deliled.Applications.android.Maestro.MainActivity.lum_zone_3;
import static deliled.Applications.android.Maestro.MainActivity.lum_zone_4;
import static deliled.Applications.android.Maestro.MainActivity.mConnected;
import static deliled.Applications.android.Maestro.MainActivity.mDeviceAddress;
import static deliled.Applications.android.Maestro.MainActivity.mGattCharacteristics;
import static deliled.Applications.android.Maestro.MainActivity.state;
import static deliled.Applications.android.Maestro.MainActivity.write_profils;
import static deliled.Applications.android.Maestro.MainActivity.zones_lum_fixe;
import static deliled.Applications.android.Maestro.MainActivity.myswitch;
import static deliled.Applications.android.Maestro.fragment.ProfilsFragment.what_lum;

public class ajustement_luminosite extends Activity {
    SeekBar lum_zone1,lum_zone2,lum_zone3,lum_zone4,lum_010v;
    TextView zone1_lum,zone2_lum,zone3_lum,zone4_lum,l010v_lum;
    ToggleButton lumi_zone_1,lumi_zone_2,lumi_zone_3,lumi_zone_4,volt_zone;
    ToggleButton lumi_manu_zone1,lumi_manu_zone2,lumi_manu_zone3,lumi_manu_zone4,lumi_manu_zonevolt;
    Spinner time_on_heu_1,time_on_min_1,time_on_heu_2,time_on_min_2,time_off_heu_1,time_off_min_1,time_off_heu_2,time_off_min_2
            ,val_zone_on_1_1,val_zone_on_2_1,val_zone_on_3_1,val_zone_on_4_1,val_zone_on_volt_1
            ,val_zone_off_1_1,val_zone_off_2_1,val_zone_off_3_1,val_zone_off_4_1,val_zone_off_volt_1
            ,val_zone_on_1_2,val_zone_on_2_2,val_zone_on_3_2,val_zone_on_4_2,val_zone_on_volt_2
            ,val_zone_off_1_2,val_zone_off_2_2,val_zone_off_3_2,val_zone_off_4_2,val_zone_off_volt_2;
    Button test_lum;
    CheckBox Tewenty_Percent;
    TextView auto_lim;
    CountDownTimer timer_luminosity;
    boolean Paused = false;
    boolean Canceled = false;
    boolean chPaused = false;
    boolean chCanceled = false;
    public int moyenne_luminosity=0;
    public float luminosity=0;
    public int cpp=0;
    public BluetoothLeService mBluetoothLeService;
    public BluetoothGattCharacteristic mNotifyCharacteristic;
    public ArrayList<ArrayList<BluetoothGattCharacteristic>> mGattlumCharacteristics = new ArrayList<>();
    public Boolean setting =true;
    public  ArrayAdapter<String> adapter_profile;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.luminoste);
        getActionBar().setIcon(R.drawable.lumiair);
        if (what_lum)
        {
            RelativeLayout auto=findViewById(R.id.lum_auto);
            LinearLayout fixe=findViewById(R.id.linear_manuelle);
            auto.setVisibility(View.VISIBLE);
            fixe.setVisibility(View.GONE);
            getActionBar().setTitle("Automatique");
        }
        else
        {
            RelativeLayout auto=findViewById(R.id.lum_auto);
            LinearLayout fixe=findViewById(R.id.linear_manuelle);
            auto.setVisibility(View.GONE);
            fixe.setVisibility(View.VISIBLE);
            getActionBar().setTitle("Manuel");

        }
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        Intent gattServiceIntent = new Intent(this, BluetoothLeService.class);
        bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE);
        mGattlumCharacteristics=mGattCharacteristics;
        getActionBar().setDisplayHomeAsUpEnabled(true);
        lumi_manu_zone1=findViewById(R.id.lum_zone_start_manu_1);
        lumi_manu_zone2=findViewById(R.id.lum_zone_start_manu_2);
        lumi_manu_zone3=findViewById(R.id.lum_zone_start_manu_3);
        lumi_manu_zone4=findViewById(R.id.lum_zone_start_manu_4);
        lumi_manu_zonevolt=findViewById(R.id.lum_zone_start_manu_volt);
        val_zone_off_1_1=findViewById(R.id.lum_mid_manu_1);
        val_zone_off_2_1=findViewById(R.id.lum_mid_manu_2);
        val_zone_off_3_1=findViewById(R.id.lum_mid_manu_3);
        val_zone_off_4_1=findViewById(R.id.lum_mid_manu_4);
        val_zone_off_volt_1=findViewById(R.id.lum_mid_manu_volt);
        time_on_heu_1=findViewById(R.id.lum_heure_start);
        time_on_min_1=findViewById(R.id.lum_minute_start);
        time_off_heu_1=findViewById(R.id.lum_heure_mid);
        time_off_min_1=findViewById(R.id.lum_minute_mid);
        time_on_heu_2=findViewById(R.id.lum_heure_end);
        time_on_min_2=findViewById(R.id.lum_minute_end);
        time_off_heu_2=findViewById(R.id.lum_heure_end_2);
        time_off_min_2=findViewById(R.id.lum_minute_end_2);
        val_zone_on_1_1=findViewById(R.id.lum_start_manu_1);
        val_zone_on_2_1=findViewById(R.id.lum_start_manu_2);
        val_zone_on_3_1=findViewById(R.id.lum_start_manu_3);
        val_zone_on_4_1=findViewById(R.id.lum_start_manu_4);
        val_zone_on_volt_1=findViewById(R.id.lum_start_manu_volt);
        val_zone_on_1_2=findViewById(R.id.lum_end_manu_1);
        val_zone_on_2_2=findViewById(R.id.lum_end_manu_2);
        val_zone_on_3_2=findViewById(R.id.lum_end_manu_3);
        val_zone_on_4_2=findViewById(R.id.lum_end_manu_4);
        val_zone_on_volt_2=findViewById(R.id.lum_end_manu_volt);
        val_zone_off_1_2=findViewById(R.id.lum_end_manu_1_2);
        val_zone_off_2_2=findViewById(R.id.lum_end_manu_2_2);
        val_zone_off_3_2=findViewById(R.id.lum_end_manu_3_2);
        val_zone_off_4_2=findViewById(R.id.lum_end_manu_4_2);
        val_zone_off_volt_2=findViewById(R.id.lum_end_manu_volt_2);
        lum_zone1=findViewById(R.id.lum_bar_zone1);
        lum_zone2=findViewById(R.id.lum_bar_zone2);
        lum_zone3=findViewById(R.id.lum_bar_zone3);
        lum_zone4=findViewById(R.id.lum_bar_zone4);
        lum_010v=findViewById(R.id.lum_bar_volt_zone);
        zone1_lum=findViewById(R.id.lum_zone1_val);
        zone2_lum=findViewById(R.id.lum_zone2_val);
        zone3_lum=findViewById(R.id.lum_zone3_val);
        zone4_lum=findViewById(R.id.lum_zone4_val);
        l010v_lum=findViewById(R.id.lum_bar_volt_zone_value);
        auto_lim=findViewById(R.id.lux_auto);
        Tewenty_Percent=findViewById(R.id.twenty_percent);
        test_lum=findViewById(R.id.test_lumi);
        lumi_zone_1=findViewById(R.id.lum_zone1);
        lumi_zone_2=findViewById(R.id.lum_zone2);
        lumi_zone_3=findViewById(R.id.lum_zone3);
        lumi_zone_4=findViewById(R.id.lum_zone4);
        volt_zone=findViewById(R.id.volt_zone);
        adapter_profile = new ArrayAdapter<>(this, R.layout.spinner_item, getResources().getStringArray(R.array.lum_level));
        adapter_profile.setDropDownViewResource(R.layout.drop_list_spinner);
        val_zone_on_1_1.setAdapter(adapter_profile);val_zone_on_2_1.setAdapter(adapter_profile);val_zone_on_3_1.setAdapter(adapter_profile);val_zone_on_4_1.setAdapter(adapter_profile);val_zone_on_volt_1.setAdapter(adapter_profile);
        val_zone_off_1_1.setAdapter(adapter_profile);val_zone_off_2_1.setAdapter(adapter_profile);val_zone_off_3_1.setAdapter(adapter_profile);val_zone_off_4_1.setAdapter(adapter_profile);val_zone_off_volt_1.setAdapter(adapter_profile);
        val_zone_on_1_2.setAdapter(adapter_profile);val_zone_on_2_2.setAdapter(adapter_profile);val_zone_on_3_2.setAdapter(adapter_profile);val_zone_on_4_2.setAdapter(adapter_profile);val_zone_on_volt_2.setAdapter(adapter_profile);
        val_zone_off_1_2.setAdapter(adapter_profile);val_zone_off_2_2.setAdapter(adapter_profile);val_zone_off_3_2.setAdapter(adapter_profile);val_zone_off_4_2.setAdapter(adapter_profile);val_zone_off_volt_2.setAdapter(adapter_profile);
        adapter_profile = new ArrayAdapter<>(this, R.layout.spinner_item, getResources().getStringArray(R.array.heure));
        adapter_profile.setDropDownViewResource(R.layout.drop_list_spinner);
        time_off_heu_1.setAdapter(adapter_profile);time_on_heu_1.setAdapter(adapter_profile);time_on_heu_2.setAdapter(adapter_profile);time_off_heu_2.setAdapter(adapter_profile);
        adapter_profile = new ArrayAdapter<>(this, R.layout.spinner_item, getResources().getStringArray(R.array.minute));
        adapter_profile.setDropDownViewResource(R.layout.drop_list_spinner);
        time_off_min_1.setAdapter(adapter_profile);time_on_min_1.setAdapter(adapter_profile);time_on_min_2.setAdapter(adapter_profile);time_off_min_2.setAdapter(adapter_profile);
        write=false;
        Tewenty_Percent.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(Tewenty_Percent.isChecked()){
                    lum_tewenty_percent=1;
                    if(write) {
                        if (mConnected) {
                            writecharacteristic(3, 1, "{\"seuil\":[" + lum_tewenty_percent + "]}");
                        }
                    }
                }else {
                    lum_tewenty_percent=0;
                    if(write) {
                        if (mConnected) {
                            writecharacteristic(3, 1, "{\"seuil\":[" + lum_tewenty_percent + "]}");
                        }
                    }
                }
            }
        });
        test_lum.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Canceled=false;
                Paused=false;
                LinearLayout layout = new LinearLayout(getApplication().getApplicationContext());
                layout.setOrientation(LinearLayout.VERTICAL);
                layout.setGravity(Gravity.CENTER);
                final ProgressBar progress = new ProgressBar(getApplication().getApplicationContext());
                layout.addView(progress);
                final AlertDialog.Builder builder = new AlertDialog.Builder(ajustement_luminosite.this);
                builder.setCancelable(false)
                        .setTitle("Test sur la luminosité")
                        .setMessage("Veuillez patienter lors du calibrage de la luminosité")
                        .setView(layout);
                final AlertDialog alert = builder.create();
                alert.show();
                moyenne_luminosity=0;
                cpp=0;
                timer_luminosity =new CountDownTimer(1000, 1000) {
                    public void onTick(long l) {
                        if(Paused || Canceled) {
                            //If the user request to cancel or paused the
                            //CountDownTimer we will cancel the current instance
                            cancel();
                        }
                    }
                    public void onFinish() {
                        moyenne_luminosity =moyenne_luminosity+ Udata_als;
                        System.out.println("la valeur moyenne est = "+moyenne_luminosity);
                        if (cpp==4)
                        {
                            alert.dismiss();
                            Canceled=true;
                            Paused=true;
                            luminosity=(float)moyenne_luminosity/5;
                            save();
                            if (mConnected) {
                                Boolean check = false;
                                do {
                                    check = writecharacteristic(3, 0, "{\"lum\":["+ lum_active+ ","+ auto_val+",\""+ Zone_lum+"\","+ lum_zone_1+ ","+ lum_zone_2+","+ lum_zone_3+","+ lum_zone_4+","+ lum_zone_010v+ ","+ lum_tewenty_percent+","+
                                            auto_or_fixe+",\""+zones_lum_fixe+"\","+lum_start_fixe_zone_1_1+","+lum_start_fixe_zone_2_1+","+lum_start_fixe_zone_3_1+","+lum_start_fixe_zone_4_1+","+lum_fixe_start_zone_volt_1+
                                            ","+lum_fixe_start_h_1+""+format(lum_fixe_start_m_1)+
                                            ","+lum_fixe_start_h_2+""+format(lum_fixe_start_m_2)+","+lum_start_fixe_zone_1_2+","+lum_start_fixe_zone_2_2+","+lum_start_fixe_zone_3_2+","+lum_start_fixe_zone_4_2+","+lum_fixe_start_zone_volt_2+
                                            ","+lum_fixe_end_h_1+""+format(lum_fixe_end_m_1)+","+lum_end_fixe_zone_1_1+","+lum_end_fixe_zone_2_1+","+lum_end_fixe_zone_3_1+","+lum_end_fixe_zone_4_1+","+lum_end_fixe_zone_volt_1+
                                            ","+lum_fixe_end_h_2+""+format(lum_fixe_end_m_2)+","+lum_end_fixe_zone_1_2+","+lum_end_fixe_zone_2_2+","+lum_end_fixe_zone_3_2+","+lum_end_fixe_zone_4_2+","+lum_end_fixe_zone_volt_2+"]}");


                                    if (check) {
                                        Toast.makeText(ajustement_luminosite.this, "la valeure moyenne de la luminosité est = " + luminosity, Toast.LENGTH_LONG).show();
                                    }
                                }
                                while (!check);
                            }
                            cpp=0;
                        }
                        cpp++;
                        start();
                    }
                };
                timer_luminosity.start();
            }
        });
        lum_zone1.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                String progres = seekBar.getProgress() + "%";
                zone1_lum.setText(progres);
                setting=false;
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (lumi_zone_1.isChecked()) {
                    String progres = seekBar.getProgress() + "%";
                    zone1_lum.setText(progres);
                    String liminosity = "{\"light_zone\":[7," + progres + ",\"1\","+lum_tewenty_percent+"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });
        lum_zone2.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                String progres = seekBar.getProgress() + "%";
                zone2_lum.setText(progres);
                setting=false;
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (lumi_zone_2.isChecked()) {
                    String progres = seekBar.getProgress() + "%";
                    zone2_lum.setText(progres);
                    String liminosity = "{\"light_zone\":[7," + progres + ",\"2\","+lum_tewenty_percent+"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });
        lum_zone3.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                String progres = seekBar.getProgress() + "%";
                zone3_lum.setText(progres);
                setting=false;
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (lumi_zone_3.isChecked()) {
                    String progres = seekBar.getProgress() + "%";
                    zone3_lum.setText(progres);
                    String liminosity = "{\"light_zone\":[7," + progres + ",\"4\","+lum_tewenty_percent+"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });
        lum_zone4.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                String progres = seekBar.getProgress() + "%";
                zone4_lum.setText(progres);
                setting=false;
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (lumi_zone_4.isChecked()) {
                    String progres = seekBar.getProgress() + "%";
                    zone4_lum.setText(progres);
                    String liminosity = "{\"light_zone\":[7," + progres + ",\"8\","+lum_tewenty_percent+"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });
        lum_010v.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
            {
                String progres = seekBar.getProgress() + "%";
                l010v_lum.setText(progres);
                setting=false;
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                if (volt_zone.isChecked()) {
                    String progres = seekBar.getProgress() + "%";
                    l010v_lum.setText(progres);
                    String liminosity = "{\"light_zone\":[7," + progres + ",\"10\","+lum_tewenty_percent+"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });
        select_room();
        check_lum();
        read_profile();
    }

    public void check_lum(){
         new CountDownTimer(1000, 1000) {
            public void onTick(long l) {
                if(chPaused || chCanceled) {
                    //If the user request to cancel or paused the
                    //CountDownTimer we will cancel the current instance
                    cancel();
                }
            }
            public void onFinish() {
                String lum=Integer.toString(Udata_als);
                auto_lim.setText(lum);
                if (setting)
                {
                    if (lumi_zone_1.isChecked()) {
                        lum_zone1.setProgress(Udata_lum_zone_1);
                    }
                    if (lumi_zone_2.isChecked()) {
                        lum_zone2.setProgress(Udata_lum_zone_2);
                    }
                    if (lumi_zone_3.isChecked()) {
                        lum_zone3.setProgress(Udata_lum_zone_3);
                    }
                    if (lumi_zone_4.isChecked()) {
                        lum_zone4.setProgress(Udata_lum_zone_4);
                    }
                    if (volt_zone.isChecked()) {
                        lum_010v.setProgress(Udata_lum_zone_010v);
                    }
                }
                setting=true;
                start();
            }
        }.start();
    }

    public boolean write;
    public void  select_room(){
        volt_zone.setText(R.string.volt);
        volt_zone.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (volt_zone.isChecked()){
                    z10v=1;
                    volt_zone.setTextOn("0/10V");
                    volt_zone.setTextColor(getResources().getColor(R.color.RoyalBlue));
                }else {
                    z10v=0;
                    volt_zone.setTextOff("0/10V");
                    volt_zone.setTextColor(getResources().getColor(R.color.White));
                }
                Zone_lum =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                if(write)
                {
                    checkzone();
                    String liminosity = "{\"zone_lum\":[\""+Zone_lum+"\"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });
        lumi_zone_1.setText(Zone_1);
        lumi_zone_1.setTextOn(Zone_1);
        lumi_zone_1.setTextOff(Zone_1);
        lumi_zone_2.setText(Zone_2);
        lumi_zone_2.setTextOn(Zone_2);
        lumi_zone_2.setTextOff(Zone_2);
        lumi_zone_3.setText(Zone_3);
        lumi_zone_3.setTextOn(Zone_3);
        lumi_zone_3.setTextOff(Zone_3);
        lumi_zone_4.setText(Zone_4);
        lumi_zone_4.setTextOn(Zone_4);
        lumi_zone_4.setTextOff(Zone_4);
        lumi_zone_1.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener(){
            @Override
            public void onCheckedChanged(CompoundButton buttonView,boolean isChecked){
                if (lumi_zone_1.isChecked()) {
                    Z1 =1;
                    lumi_zone_1.setTextColor(getResources().getColor(R.color.RoyalBlue));
                } else {
                    Z1=0;
                    lumi_zone_1.setTextColor(getResources().getColor(R.color.White));
                }
                Zone_lum =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                if(write)
                {
                    checkzone();
                    String liminosity = "{\"zone_lum\":[\""+Zone_lum+"\"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });

        lumi_zone_2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView,boolean isChecked) {
                if (lumi_zone_2.isChecked()) {
                    Z2 =1;
                    lumi_zone_2.setTextColor(getResources().getColor(R.color.RoyalBlue));
                } else {
                    Z2 =0;
                    lumi_zone_2.setTextColor(getResources().getColor(R.color.White));
                }
                Zone_lum =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                if(write)
                {
                    checkzone();
                    String liminosity = "{\"zone_lum\":[\""+Zone_lum+"\"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });
        lumi_zone_3.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView,boolean isChecked) {
                if (lumi_zone_3.isChecked()) {
                    Z3 =1;
                    lumi_zone_3.setTextColor(getResources().getColor(R.color.RoyalBlue));
                } else {
                    Z3 =0;
                    lumi_zone_3.setTextColor(getResources().getColor(R.color.White));
                }
                Zone_lum =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                if(write)
                {
                    checkzone();
                    String liminosity = "{\"zone_lum\":[\""+Zone_lum+"\"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });
        lumi_zone_4.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView,boolean isChecked) {
                if (lumi_zone_4.isChecked()) {
                    Z4 =1;
                    lumi_zone_4.setTextColor(getResources().getColor(R.color.RoyalBlue));
                } else {
                    Z4 =0;
                    lumi_zone_4.setTextColor(getResources().getColor(R.color.White));
                }
                Zone_lum =Integer.toString((z10v*16)+(Z4*8)+(Z3*4)+(Z2*2)+Z1, 16);
                if(write)
                {
                    checkzone();
                    String liminosity = "{\"zone_lum\":[\""+Zone_lum+"\"]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, liminosity);
                }
            }
        });
    }
    public void checkzone()
    {
        int z_1,z_2,z_3,z_4,z_5;
        if (lumi_zone_1.isChecked()){z_1=1;}else{z_1=0;}
        if (lumi_zone_2.isChecked()){z_2=1;}else{z_2=0;}
        if (lumi_zone_3.isChecked()){z_3=1;}else{z_3=0;}
        if (lumi_zone_4.isChecked()){z_4=1;}else{z_4=0;}
        if (volt_zone.isChecked()){z_5=1;}else{z_5=0;}
        Zone_lum =Integer.toString((z_5*16)+(z_4*8)+(z_3*4)+(z_2*2)+z_1, 16);
    }
    int zone_v;
    int z10v;
    int Z4 ;
    int Z3 ;
    int Z2 ;
    int Z1 ;

    public static boolean isHexNumber (String cadena) {
        try {
            Long.parseLong(cadena, 16);
            return true;
        }
        catch (NumberFormatException ex) {
            // Error handling code...
            ex.printStackTrace();
            return false;
        }
    }
    public void read_profile()
    {
        if(!isHexNumber(Zone_lum))
        {
            Zone_lum="0";
        }
        zone_v = Integer.parseInt(Zone_lum, 16);
        z10v = zone_v / 16;
        Z4 = zone_v % 16 / 8;
        Z3 = zone_v % 8 / 4;
        Z2 = zone_v % 4 / 2;
        Z1 = zone_v % 2;
        lum_zone1.setProgress(Udata_lum_zone_1);
        lum_zone2.setProgress(Udata_lum_zone_2);
        lum_zone3.setProgress(Udata_lum_zone_3);
        lum_zone4.setProgress(Udata_lum_zone_4);
        lum_010v.setProgress(Udata_lum_zone_010v);
        lumi_zone_1.setTextColor(getResources().getColor(R.color.White));
        lumi_zone_2.setTextColor(getResources().getColor(R.color.White));
        lumi_zone_3.setTextColor(getResources().getColor(R.color.White));
        lumi_zone_4.setTextColor(getResources().getColor(R.color.White));
        volt_zone.setTextColor(getResources().getColor(R.color.White));
        if (Z1 == 0) {
            lumi_zone_1.setChecked(false);
        } else {
            lumi_zone_1.setChecked(true);
        }
        if (Z2 == 0) {
            lumi_zone_2.setChecked(false);
        } else {
            lumi_zone_2.setChecked(true);
        }
        if (Z3 == 0) {
            lumi_zone_3.setChecked(false);
        } else {
            lumi_zone_3.setChecked(true);
        }
        if (Z4 == 0) {
            lumi_zone_4.setChecked(false);
        } else {
            lumi_zone_4.setChecked(true);
        }
        if (z10v == 0) {
            volt_zone.setChecked(false);
        } else {
            volt_zone.setChecked(true);
        }
        if (lum_tewenty_percent==1){
            Tewenty_Percent.setChecked(true);
        }else {
            Tewenty_Percent.setChecked(false);
        }
        if(!isHexNumber(zones_lum_fixe))
        {
            zones_lum_fixe="0";
        }
        zone_v = Integer.parseInt(zones_lum_fixe, 16);
        z10v = zone_v / 16;
        Z4 = zone_v % 16 / 8;
        Z3 = zone_v % 8 / 4;
        Z2 = zone_v % 4 / 2;
        Z1 = zone_v % 2;
        if (Z1 == 0) {
            lumi_manu_zone1.setChecked(false);
        } else {
            lumi_manu_zone1.setChecked(true);
        }
        if (Z2 == 0) {
            lumi_manu_zone2.setChecked(false);
        } else {
            lumi_manu_zone2.setChecked(true);
        }
        if (Z3 == 0) {
            lumi_manu_zone3.setChecked(false);
        } else {
            lumi_manu_zone3.setChecked(true);
        }
        if (Z4 == 0) {
            lumi_manu_zone4.setChecked(false);
        } else {
            lumi_manu_zone4.setChecked(true);
        }
        if (z10v == 0) {
            lumi_manu_zonevolt.setChecked(false);
        } else {
            lumi_manu_zonevolt.setChecked(true);
        }

        time_on_heu_1.setSelection(lum_fixe_start_h_1);time_on_min_1.setSelection(lum_fixe_start_m_1);
        time_on_heu_2.setSelection(lum_fixe_start_h_2);time_on_min_2.setSelection(lum_fixe_start_m_2);
        time_off_heu_1.setSelection(lum_fixe_end_h_1);time_off_min_1.setSelection(lum_fixe_end_m_1);
        time_off_heu_2.setSelection(lum_fixe_end_h_2);time_off_min_2.setSelection(lum_fixe_end_m_2);

        val_zone_on_1_1.setSelection(lum_start_fixe_zone_1_1);val_zone_on_2_1.setSelection(lum_start_fixe_zone_2_1);val_zone_on_3_1.setSelection(lum_start_fixe_zone_3_1);val_zone_on_4_1.setSelection(lum_start_fixe_zone_4_1);val_zone_on_volt_1.setSelection(lum_fixe_start_zone_volt_1);
        val_zone_off_1_1.setSelection(lum_end_fixe_zone_1_1);val_zone_off_2_1.setSelection(lum_end_fixe_zone_2_1);val_zone_off_3_1.setSelection(lum_end_fixe_zone_3_1);val_zone_off_4_1.setSelection(lum_end_fixe_zone_4_1);val_zone_off_volt_1.setSelection(lum_end_fixe_zone_volt_1);
        val_zone_on_1_2.setSelection(lum_start_fixe_zone_1_2);val_zone_on_2_2.setSelection(lum_start_fixe_zone_2_2);val_zone_on_3_2.setSelection(lum_start_fixe_zone_3_2);val_zone_on_4_2.setSelection(lum_start_fixe_zone_4_2);val_zone_on_volt_2.setSelection(lum_fixe_start_zone_volt_2);
        val_zone_off_1_2.setSelection(lum_end_fixe_zone_1_2);val_zone_off_2_2.setSelection(lum_end_fixe_zone_2_2);val_zone_off_3_2.setSelection(lum_end_fixe_zone_3_2);val_zone_off_4_2.setSelection(lum_end_fixe_zone_4_2);val_zone_off_volt_2.setSelection(lum_end_fixe_zone_volt_2);

        write=true;
    }
    public void save(){
        if(Tewenty_Percent.isChecked()){
            lum_tewenty_percent=1;
        }else {
            lum_tewenty_percent=0;
        }
        if (!((int)luminosity==0))
        {
            auto_val=(int)luminosity;
        }
        lum_zone_1=lum_zone1.getProgress();
        lum_zone_2=lum_zone2.getProgress();
        lum_zone_3=lum_zone3.getProgress();
        lum_zone_4=lum_zone4.getProgress();
        lum_zone_010v=lum_010v.getProgress();
        int z_1,z_2,z_3,z_4,z_5;
        if (lumi_zone_1.isChecked()){z_1=1;}else{z_1=0;}
        if (lumi_zone_2.isChecked()){z_2=1;}else{z_2=0;}
        if (lumi_zone_3.isChecked()){z_3=1;}else{z_3=0;}
        if (lumi_zone_4.isChecked()){z_4=1;}else{z_4=0;}
        if (volt_zone.isChecked()){z_5=1;}else{z_5=0;}
        Zone_lum =Integer.toString((z_5*16)+(z_4*8)+(z_3*4)+(z_2*2)+z_1, 16);
        if (lumi_manu_zone1.isChecked()){z_1=1;}else{z_1=0;}
        if (lumi_manu_zone2.isChecked()){z_2=1;}else{z_2=0;}
        if (lumi_manu_zone3.isChecked()){z_3=1;}else{z_3=0;}
        if (lumi_manu_zone4.isChecked()){z_4=1;}else{z_4=0;}
        if (lumi_manu_zonevolt.isChecked()){z_5=1;}else{z_5=0;}
        zones_lum_fixe =Integer.toString((z_5*16)+(z_4*8)+(z_3*4)+(z_2*2)+z_1, 16);
        lum_start_fixe_zone_1_1=val_zone_on_1_1.getSelectedItemPosition();
        lum_start_fixe_zone_2_1=val_zone_on_2_1.getSelectedItemPosition();
        lum_start_fixe_zone_3_1=val_zone_on_3_1.getSelectedItemPosition();
        lum_start_fixe_zone_4_1=val_zone_on_4_1.getSelectedItemPosition();
        lum_fixe_start_zone_volt_1=val_zone_on_volt_1.getSelectedItemPosition();
        lum_fixe_start_h_1=time_on_heu_1.getSelectedItemPosition();
        lum_fixe_start_m_1=time_on_min_1.getSelectedItemPosition();
        lum_fixe_start_h_2=time_on_heu_2.getSelectedItemPosition();
        lum_fixe_start_m_2=time_on_min_2.getSelectedItemPosition();
        lum_fixe_end_h_1=time_off_heu_1.getSelectedItemPosition();
        lum_fixe_end_m_1=time_off_min_1.getSelectedItemPosition();
        lum_fixe_end_h_2=time_off_heu_2.getSelectedItemPosition();
        lum_fixe_end_m_2=time_off_min_2.getSelectedItemPosition();
        lum_end_fixe_zone_1_1=val_zone_off_1_1.getSelectedItemPosition();
        lum_end_fixe_zone_2_1=val_zone_off_2_1.getSelectedItemPosition();
        lum_end_fixe_zone_3_1=val_zone_off_3_1.getSelectedItemPosition();
        lum_end_fixe_zone_4_1=val_zone_off_4_1.getSelectedItemPosition();
        lum_end_fixe_zone_volt_1=val_zone_off_volt_1.getSelectedItemPosition();
        lum_start_fixe_zone_1_2=val_zone_on_1_2.getSelectedItemPosition();
        lum_start_fixe_zone_2_2=val_zone_on_2_2.getSelectedItemPosition();
        lum_start_fixe_zone_3_2=val_zone_on_3_2.getSelectedItemPosition();
        lum_start_fixe_zone_4_2=val_zone_on_4_2.getSelectedItemPosition();
        lum_fixe_start_zone_volt_2=val_zone_on_volt_2.getSelectedItemPosition();
        lum_end_fixe_zone_1_2=val_zone_off_1_2.getSelectedItemPosition();
        lum_end_fixe_zone_2_2=val_zone_off_2_2.getSelectedItemPosition();
        lum_end_fixe_zone_3_2=val_zone_off_3_2.getSelectedItemPosition();
        lum_end_fixe_zone_4_2=val_zone_off_4_2.getSelectedItemPosition();
        lum_end_fixe_zone_volt_2=val_zone_off_volt_2.getSelectedItemPosition();
    }
    public String format (int x)
    {
        return String.format("%02d",x);
    }
    @Override
    public void onBackPressed()
    {
        save();
        chCanceled=true;
        chPaused=true;
        if (mConnected)
        {
            Boolean check = false;
            do {
                check = writecharacteristic(3, 0, "{\"lum\":["+ lum_active+ ","+ auto_val+",\""+ Zone_lum+"\","+ lum_zone_1+ ","+ lum_zone_2+","+ lum_zone_3+","+ lum_zone_4+","+ lum_zone_010v+ ","+ lum_tewenty_percent+","+
                                auto_or_fixe+",\""+zones_lum_fixe+
                        "\","+lum_start_fixe_zone_1_1+","+lum_start_fixe_zone_2_1+","+lum_start_fixe_zone_3_1+","+lum_start_fixe_zone_4_1+","+lum_fixe_start_zone_volt_1+ ","+lum_fixe_start_h_1+""+format(lum_fixe_start_m_1)+
                        ","+lum_fixe_start_h_2+""+format(lum_fixe_start_m_2)+","+lum_start_fixe_zone_1_2+","+lum_start_fixe_zone_2_2+","+lum_start_fixe_zone_3_2+","+lum_start_fixe_zone_4_2+","+lum_fixe_start_zone_volt_2+
                        ","+lum_fixe_end_h_1+""+format(lum_fixe_end_m_1)+","+lum_end_fixe_zone_1_1+","+lum_end_fixe_zone_2_1+","+lum_end_fixe_zone_3_1+","+lum_end_fixe_zone_4_1+","+lum_end_fixe_zone_volt_1+
                        ","+lum_fixe_end_h_2+""+format(lum_fixe_end_m_2)+","+lum_end_fixe_zone_1_2+","+lum_end_fixe_zone_2_2+","+lum_end_fixe_zone_3_2+","+lum_end_fixe_zone_4_2+","+lum_end_fixe_zone_volt_2+"]}");
            }
            while (!check);
            Toast.makeText(this, "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
        }
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
    public Switch myswitch_ajust;
    public void MAN_AUTO()
    {
        myswitch_ajust = menuItem.getActionView().findViewById(R.id.manorauto);
        if (state==0)
        {
            myswitch_ajust.setChecked(false);
        }
        else
        {
            myswitch_ajust.setChecked(true);
        }
        myswitch_ajust.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
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
                                Log.i("lum", "send mode");
                                String switching = "{\"mode\":\"auto\"}";
                                state = 1;
                                check = writecharacteristic(3, 0, switching);
                            } while (check);
                        }
                    } else {
                        if (mConnected) {
                            Boolean check;
                            do {
                                Log.i("lum", "send mode");
                                String switching = "{\"mode\":\"manu\"}";
                                state = 0;
                                check = writecharacteristic(3, 0, switching);
                            }
                            while (check);
                        }
                    }
                }
            }
        });
        if(ACCESS)
        {
            myswitch_ajust.setClickable(true);
        }else {
            myswitch_ajust.setClickable(false);
        }
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch(item.getItemId())
        {
            case R.id.menu_disconnect:
                Intent i=new Intent(this, DeviceScanActivity.class);
                i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                chCanceled=true;
                chPaused=true;
                startActivity(i);
                return true;
            case android.R.id.home:
                onBackPressed();
                return true;
        }
        return super.onOptionsItemSelected(item);
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
    private final ServiceConnection mServiceConnection = new ServiceConnection()
    {

        @Override
        public void onServiceConnected(ComponentName componentName, IBinder service)
        {
            mBluetoothLeService = ((BluetoothLeService.LocalBinder) service).getService();
            if (!mBluetoothLeService.initialize())
            {
                finish();
            }
            // Automatically connects to the device upon successful start-up initialization.
            mBluetoothLeService.connect(mDeviceAddress);
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName)
        {
            mBluetoothLeService = null;
        }
    };
}
