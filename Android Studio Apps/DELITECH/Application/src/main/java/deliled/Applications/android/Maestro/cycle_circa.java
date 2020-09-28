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
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.SeekBar;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import java.util.ArrayList;


import static deliled.Applications.android.Maestro.DeviceScanActivity.ACCESS;
import static deliled.Applications.android.Maestro.MainActivity.Cc_bet_times;
import static deliled.Applications.android.Maestro.MainActivity.Enb_CC;
import static deliled.Applications.android.Maestro.MainActivity.Scene_state;
import static deliled.Applications.android.Maestro.MainActivity.Zone_1;
import static deliled.Applications.android.Maestro.MainActivity.Zone_2;
import static deliled.Applications.android.Maestro.MainActivity.Zone_3;
import static deliled.Applications.android.Maestro.MainActivity.Zone_4;
import static deliled.Applications.android.Maestro.MainActivity.Zone_CC;
import static deliled.Applications.android.Maestro.MainActivity.bleReadWrite;
import static deliled.Applications.android.Maestro.MainActivity.cyc_enb;
import static deliled.Applications.android.Maestro.MainActivity.heure_p1_h;
import static deliled.Applications.android.Maestro.MainActivity.heure_p1_m;
import static deliled.Applications.android.Maestro.MainActivity.heure_p2_h;
import static deliled.Applications.android.Maestro.MainActivity.heure_p2_m;
import static deliled.Applications.android.Maestro.MainActivity.heure_p3_h;
import static deliled.Applications.android.Maestro.MainActivity.heure_p3_m;
import static deliled.Applications.android.Maestro.MainActivity.heure_p4_h;
import static deliled.Applications.android.Maestro.MainActivity.heure_p4_m;
import static deliled.Applications.android.Maestro.MainActivity.mConnected;
import static deliled.Applications.android.Maestro.MainActivity.mDeviceAddress;
import static deliled.Applications.android.Maestro.MainActivity.mGattCharacteristics;
import static deliled.Applications.android.Maestro.MainActivity.p1_temp;
import static deliled.Applications.android.Maestro.MainActivity.p2_temp;
import static deliled.Applications.android.Maestro.MainActivity.p3_temp;
import static deliled.Applications.android.Maestro.MainActivity.p4_temp;
import static deliled.Applications.android.Maestro.MainActivity.state;
import static deliled.Applications.android.Maestro.MainActivity.write_profils;
import static deliled.Applications.android.Maestro.MainActivity.myswitch;
import static deliled.Applications.android.Maestro.ajustement_luminosite.isHexNumber;

public class cycle_circa extends Activity {

    SeekBar WHITE1,WHITE2,WHITE3,WHITE4;
    TextView BC1,BF1,BC2,BF2,BC3,BF3,BC4,BF4,test_CC;
    ToggleButton ZONE_cc_1,ZONE_cc_2,ZONE_cc_3,ZONE_cc_4;
    Switch phase_1,phase_2,phase_3,phase_4,between_phases;
    SeekBar test_EXPRESS;
    Spinner horaire_1_heur,horaire_1_min,horaire_2_heur,horaire_2_min,horaire_3_heur,horaire_3_min,horaire_4_heur,horaire_4_min;
    public BluetoothLeService mBluetoothLeService;
    public BluetoothGattCharacteristic mNotifyCharacteristic;
    public ArrayList<ArrayList<BluetoothGattCharacteristic>> mGattccCharacteristics = new ArrayList<>();


    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.cyc_circa);
        getActionBar().setIcon(R.drawable.lumiair);
        mGattccCharacteristics=mGattCharacteristics;
        Intent gattServiceIntent = new Intent(this, BluetoothLeService.class);
        bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE);
        getActionBar().setTitle("Cycle circadien");
        getActionBar().setDisplayHomeAsUpEnabled(true);
        BF1=findViewById(R.id.froid1);
        BF2=findViewById(R.id.froid2);
        BF3=findViewById(R.id.froid3);
        BF4=findViewById(R.id.froid4);
        BC1=findViewById(R.id.chaud1);
        BC2=findViewById(R.id.chaud2);
        BC3=findViewById(R.id.chaud3);
        BC4=findViewById(R.id.chaud4);
        phase_1=findViewById(R.id.PH1);
        phase_2=findViewById(R.id.PH2);
        phase_3=findViewById(R.id.PH3);
        phase_4=findViewById(R.id.PH4);
        between_phases=findViewById(R.id.between_phases);
        horaire_1_heur=findViewById(R.id.horaire_heure_1);
        horaire_2_heur=findViewById(R.id.horaire_heure_2);
        horaire_3_heur=findViewById(R.id.horaire_heure_3);
        horaire_4_heur=findViewById(R.id.horaire_heure_4);
        horaire_1_min=findViewById(R.id.horaire_minute_1);
        horaire_2_min=findViewById(R.id.horaire_minute_2);
        horaire_3_min=findViewById(R.id.horaire_minute_3);
        horaire_4_min=findViewById(R.id.horaire_minute_4);
        test_EXPRESS=findViewById(R.id.test_express);
        ZONE_cc_1=findViewById(R.id.zone1_cyc);
        ZONE_cc_2=findViewById(R.id.zone2_cyc);
        ZONE_cc_3=findViewById(R.id.zone3_cyc);
        ZONE_cc_4=findViewById(R.id.zone4_cyc);
        WHITE1=findViewById(R.id.horaire_white_1);
        WHITE2=findViewById(R.id.horaire_white_2);
        WHITE3=findViewById(R.id.horaire_white_3);
        WHITE4=findViewById(R.id.horaire_white_4);
        between_phases.setVisibility(View.GONE);
        test_CC=findViewById(R.id.test_cc);
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, R.layout.spinner_item,getResources().getStringArray(R.array.heure));
        adapter.setDropDownViewResource(R.layout.drop_list_spinner);
        horaire_1_heur.setAdapter(adapter);
        ArrayAdapter <String> adapter1 = new ArrayAdapter<>(this, R.layout.spinner_item,getResources().getStringArray(R.array.minute));
        adapter1.setDropDownViewResource(R.layout.drop_list_spinner);
        horaire_1_min.setAdapter(adapter1);
        horaire_2_heur.setAdapter(adapter);
        horaire_2_min.setAdapter(adapter1);
        horaire_3_heur.setAdapter(adapter);
        horaire_4_heur.setAdapter(adapter);
        horaire_3_min.setAdapter(adapter1);
        horaire_4_min.setAdapter(adapter1);
        ZONE_cc_1.setText(Zone_1);
        ZONE_cc_1.setTextOn(Zone_1);
        ZONE_cc_1.setTextOff(Zone_1);
        ZONE_cc_2.setText(Zone_2);
        ZONE_cc_2.setTextOn(Zone_2);
        ZONE_cc_2.setTextOff(Zone_2);
        ZONE_cc_3.setText(Zone_3);
        ZONE_cc_3.setTextOn(Zone_3);
        ZONE_cc_3.setTextOff(Zone_3);
        ZONE_cc_4.setText(Zone_4);
        ZONE_cc_4.setTextOn(Zone_4);
        ZONE_cc_4.setTextOff(Zone_4);
        test_EXPRESS.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                int z_1,z_2,z_3,z_4;
                if (ZONE_cc_1.isChecked()){z_1=1;}else{z_1=0;}
                if (ZONE_cc_2.isChecked()){z_2=1;}else{z_2=0;}
                if (ZONE_cc_3.isChecked()){z_3=1;}else{z_3=0;}
                if (ZONE_cc_4.isChecked()){z_4=1;}else{z_4=0;}
                Zone_CC =Integer.toString((z_4*8)+(z_3*4)+(z_2*2)+z_1, 16);
                String test = "{\"cctest\":[\""+Zone_CC+"\","+horaire_1_heur.getSelectedItemPosition()+""+horaire_1_min.getSelectedItemPosition()+","+WHITE1.getProgress()+
                                                          ","+horaire_2_heur.getSelectedItemPosition()+""+horaire_2_min.getSelectedItemPosition()+","+WHITE2.getProgress()+
                                                          ","+horaire_3_heur.getSelectedItemPosition()+""+horaire_3_min.getSelectedItemPosition()+","+WHITE3.getProgress()+
                                                          ","+progress+"]}";
                writecharacteristic(3,1,test);
                int heure_1= horaire_1_heur.getSelectedItemPosition()*3600;
                int heure_3= horaire_3_heur.getSelectedItemPosition()*3600;
                int min_1= horaire_1_min.getSelectedItemPosition()*60;
                int min_3= horaire_3_min.getSelectedItemPosition()*60;
                int h_1= heure_1+min_1;
                int h_3= heure_3+min_3;
                int h = h_1+(((h_3-h_1)*progress)/100);
                int hours = h / 3600;
                int minutes = (h % 3600) / 60;
                int seconds = h % 60;
                String time = String.format("%02d:%02d:%02d", hours, minutes, seconds);
                test_CC.setText(time);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                int z_1,z_2,z_3,z_4;
                if (ZONE_cc_1.isChecked()){z_1=1;}else{z_1=0;}
                if (ZONE_cc_2.isChecked()){z_2=1;}else{z_2=0;}
                if (ZONE_cc_3.isChecked()){z_3=1;}else{z_3=0;}
                if (ZONE_cc_4.isChecked()){z_4=1;}else{z_4=0;}
                Zone_CC =Integer.toString((z_4*8)+(z_3*4)+(z_2*2)+z_1, 16);
                String test = "{\"cctest\":[\""+Zone_CC+"\","+horaire_1_heur.getSelectedItemPosition()+""+horaire_1_min.getSelectedItemPosition()+","+WHITE1.getProgress()+
                        ","+horaire_2_heur.getSelectedItemPosition()+""+horaire_2_min.getSelectedItemPosition()+","+WHITE2.getProgress()+
                        ","+horaire_3_heur.getSelectedItemPosition()+""+horaire_3_min.getSelectedItemPosition()+","+WHITE3.getProgress()+
                        ","+seekBar.getProgress()+"]}";
                writecharacteristic(3,1,test);
                int heure_1= horaire_1_heur.getSelectedItemPosition()*3600;
                int heure_3= horaire_3_heur.getSelectedItemPosition()*3600;
                int min_1= horaire_1_min.getSelectedItemPosition()*60;
                int min_3= horaire_3_min.getSelectedItemPosition()*60;
                int h_1= heure_1+min_1;
                int h_3= heure_3+min_3;
                int h = h_1+(((h_3-h_1)*seekBar.getProgress())/100);
                int hours = h / 3600;
                int minutes = (h % 3600) / 60;
                int seconds = h % 60;
                String time = String.format("%02d:%02d:%02d", hours, minutes, seconds);
                test_CC.setText(time);
            }
        });
        WHITE1.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                String blanc_chaud=""+progress+"%";
                BC1.setText(blanc_chaud);
                int blanc_fr=Math.abs(progress-100);
                String blanc_froid=""+blanc_fr+"%";
                BF1.setText(blanc_froid);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        WHITE2.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                String blanc_chaud=""+progress+"%";
                BC2.setText(blanc_chaud);
                int blanc_fr=Math.abs(progress-100);
                String blanc_froid=""+blanc_fr+"%";
                BF2.setText(blanc_froid);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        WHITE3.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                String blanc_chaud=""+progress+"%";
                BC3.setText(blanc_chaud);
                int blanc_fr=Math.abs(progress-100);
                String blanc_froid=""+blanc_fr+"%";
                BF3.setText(blanc_froid);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        WHITE4.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                String blanc_chaud=""+progress+"%";
                BC4.setText(blanc_chaud);
                int blanc_fr=Math.abs(progress-100);
                String blanc_froid=""+blanc_fr+"%";
                BF4.setText(blanc_froid);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        read_profile();
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
    public void read_profile(){
        if(!isHexNumber(Zone_CC))
        {
            Zone_CC="0";
        }
        int zone = Integer.parseInt(Zone_CC,16);
        int z4 = zone/8;
        int z3 = zone%8/4;
        int z2 = zone%4/2;
        int z1 = zone%2;
        if (z1==0){ZONE_cc_1.setChecked(false);}else{ZONE_cc_1.setChecked(true);}
        if (z2==0){ZONE_cc_2.setChecked(false);}else{ZONE_cc_2.setChecked(true);}
        if (z3==0){ZONE_cc_3.setChecked(false);}else{ZONE_cc_3.setChecked(true);}
        if (z4==0){ZONE_cc_4.setChecked(false);}else{ZONE_cc_4.setChecked(true);}
        if(!isHexNumber(Enb_CC))
        {
            Enb_CC="0";
        }
        zone = Integer.parseInt(Enb_CC,16);
         z4 = zone/8;
         z3 = zone%8/4;
         z2 = zone%4/2;
         z1 = zone%2;
        if (z1==0){phase_4.setChecked(false);}else{phase_4.setChecked(true);}
        if (z2==0){phase_3.setChecked(false);}else{phase_3.setChecked(true);}
        if (z3==0){phase_2.setChecked(false);}else{phase_2.setChecked(true);}
        if (z4==0){phase_1.setChecked(false);}else{phase_1.setChecked(true);}
        if (Cc_bet_times==0){
            between_phases.setChecked(false);
        }else
        {
            between_phases.setChecked(true);
        }
        ZONE_cc_1.setTextColor(getResources().getColor(R.color.White));
        ZONE_cc_2.setTextColor(getResources().getColor(R.color.White));
        ZONE_cc_3.setTextColor(getResources().getColor(R.color.White));
        ZONE_cc_4.setTextColor(getResources().getColor(R.color.White));
        horaire_1_heur.setSelection(heure_p1_h);
        horaire_2_heur.setSelection(heure_p2_h);
        horaire_3_heur.setSelection(heure_p3_h);
        horaire_4_heur.setSelection(heure_p4_h);
        horaire_1_min.setSelection(heure_p1_m);
        horaire_2_min.setSelection(heure_p2_m);
        horaire_3_min.setSelection(heure_p3_m);
        horaire_4_min.setSelection(heure_p4_m);
        WHITE1.setProgress(p1_temp);
        WHITE2.setProgress(p2_temp);
        WHITE3.setProgress(p3_temp);
        WHITE4.setProgress(p4_temp);
    }
    public void save(){
        int z_1,z_2,z_3,z_4;
        if (ZONE_cc_1.isChecked()){z_1=1;}else{z_1=0;}
        if (ZONE_cc_2.isChecked()){z_2=1;}else{z_2=0;}
        if (ZONE_cc_3.isChecked()){z_3=1;}else{z_3=0;}
        if (ZONE_cc_4.isChecked()){z_4=1;}else{z_4=0;}
        Zone_CC =Integer.toString((z_4*8)+(z_3*4)+(z_2*2)+z_1, 16);
        if (phase_1.isChecked()){z_1=1;}else{z_1=0;}
        if (phase_2.isChecked()){z_2=1;}else{z_2=0;}
        if (phase_3.isChecked()){z_3=1;}else{z_3=0;}
        if (phase_4.isChecked()){z_4=1;}else{z_4=0;}
        Enb_CC =Integer.toString((z_1*8)+(z_2*4)+(z_3*2)+z_4, 16);
        if (Zone_CC.equals("null")){Zone_CC="0";}
        if (Enb_CC.equals("null")){Enb_CC="0";}
        if(between_phases.isChecked()){
            Cc_bet_times=1;
        }
        else
        {
            Cc_bet_times=0;
        }
        heure_p1_h=horaire_1_heur.getSelectedItemPosition();
        heure_p2_h=horaire_2_heur.getSelectedItemPosition();
        heure_p3_h=horaire_3_heur.getSelectedItemPosition();
        heure_p4_h=horaire_4_heur.getSelectedItemPosition();
        heure_p1_m=horaire_1_min.getSelectedItemPosition();
        heure_p2_m=horaire_2_min.getSelectedItemPosition();
        heure_p3_m=horaire_3_min.getSelectedItemPosition();
        heure_p4_m=horaire_4_min.getSelectedItemPosition();
        p1_temp=WHITE1.getProgress();
        p2_temp=WHITE2.getProgress();
        p3_temp=WHITE3.getProgress();
        p4_temp=WHITE4.getProgress();
        if (mConnected) {
            Boolean check = false;

            do {
                String cyc ="{\"cycle\":["+ cyc_enb+ ",\""+ Zone_CC+ "\",\""+ Enb_CC+ "\","+Cc_bet_times+","+ heure_p1_h+ ""+format(heure_p1_m)+","+ p1_temp+","+ heure_p2_h+""+format(heure_p2_m)+ ","+ p2_temp+","+ heure_p3_h+ ""+format(heure_p3_m)+","+ p3_temp+","+ heure_p4_h+ ""+format(heure_p4_m)+","+ p4_temp+"]}";
                check = writecharacteristic(3, 0, cyc );
                if (check) {
                    Toast.makeText(this, "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                }

            }
            while (!check);
        }
    }
    public String format (int x){
        return String.format("%02d",x);
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
    public Switch myswitch_cycle;
    public void MAN_AUTO()
    {
        myswitch_cycle = menuItem.getActionView().findViewById(R.id.manorauto);
        if (state==0)
        {
            myswitch_cycle.setChecked(false);
        }
        else
        {
            myswitch_cycle.setChecked(true);
        }
        myswitch_cycle.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
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
            myswitch_cycle.setClickable(true);
        }else {
            myswitch_cycle.setClickable(false);
        }
    }
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
