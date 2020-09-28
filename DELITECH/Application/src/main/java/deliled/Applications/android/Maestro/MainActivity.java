package deliled.Applications.android.Maestro;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.provider.Settings;
import android.speech.RecognizerIntent;
import android.speech.tts.TextToSpeech;
import androidx.annotation.NonNull;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentStatePagerAdapter;
import androidx.fragment.app.FragmentTransaction;
import androidx.viewpager.widget.ViewPager;
import androidx.appcompat.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import deliled.Applications.android.Maestro.fragment.AmbiancesFragment;
import deliled.Applications.android.Maestro.fragment.ScenesFragment;
import deliled.Applications.android.Maestro.fragment.DeviceControFragment;
import deliled.Applications.android.Maestro.fragment.ProfilsFragment;
import deliled.Applications.android.Maestro.fragment.WifiProfileNonFragment;

import static deliled.Applications.android.Maestro.BluetoothLeService.MTU_CHECKED;
import static deliled.Applications.android.Maestro.BluetoothLeService.Notification_Update;
import static deliled.Applications.android.Maestro.BluetoothLeService.STATE_DISCONNECTED;
import static deliled.Applications.android.Maestro.BluetoothLeService.createNotification;
import static deliled.Applications.android.Maestro.BluetoothLeService.mConnectionState;
import static deliled.Applications.android.Maestro.DeviceScanActivity.ACCESS;
import static deliled.Applications.android.Maestro.DeviceScanActivity.change_mode;
import static deliled.Applications.android.Maestro.FloatingWidgetService.speech_test;
import static deliled.Applications.android.Maestro.fragment.DeviceControFragment.Acceuil_isactive;
import static deliled.Applications.android.Maestro.fragment.WifiProfileNonFragment.time_esp;
import static deliled.Applications.android.Maestro.fragment.WifiProfileNonFragment.write_time;

public class MainActivity extends AppCompatActivity {
    LinearLayout ll_home, ll_fon, ll_amb, ll_scene, ll_relg;
    private ViewPager pager;
    private PageAdapter mAdapter;
    public static boolean restart_Activity;
    public static boolean restart_Scenes;
    public  static boolean mConnected = false;
    public static boolean active = false;
    private boolean isActive() {return active;}
    private final static String TAG = MainActivity.class.getSimpleName();
    public  static final String EXTRAS_DEVICE_NAME = "DEVICE_NAME";
    public  static final String EXTRAS_DEVICE_ADDRESS = "DEVICE_ADDRESS";
    public  static final int SERVICE_READ=2;
    public  static final int SERVICE_WRITE=3;
    public  static final int CHAR_READ_CAPTERS=0;
    public  static final int CHAR_READ_PROFILS=1;
    public  static final int CHAR_READ_ADVANCED=2;
    public  static final int CHAR_READ_EXPERT=3;
    public  static final int CHAR_WRITE_SYSTEM=0;
    public  static final int CHAR_WRITE_LUMINOSITY=1;
    public static String mDeviceAddress;
    public static BluetoothLeService mBluetoothLeService;
    public static ArrayList<ArrayList<BluetoothGattCharacteristic>> mGattCharacteristics = new ArrayList<>();
    private BluetoothGattCharacteristic mNotifyCharacteristic;
    public static String mDeviceName;
    public static long Udata_time,Udata_ldt;
    public static double Udata_temp,Udata_humidity;
    public static short Udata_als,Udata_co2l,Udata_tvoc;
    public static byte Udata_aq_status,indice_confinent;
    public static int Update_info,Udata_lum_zone_1,Udata_lum_zone_2,Udata_lum_zone_3,Udata_lum_zone_4,Udata_lum_zone_010v,Udata_ota,Udata_ota_checking,Udata_scene_number;
    public static Switch myswitch;
    public String time;
    public boolean dataprofile = false;
    public boolean dataserveur = false;
    public boolean datacouleur =false;
    public boolean datacapteur =false;
    public static boolean bleReadWrite = false;
    public int compter=0;

    public static boolean Saving_scene ;

    public static int heure_enc_time_h,heure_enc_2_time_h,heure_enc_time_m,heure_enc_2_time_m,veille_enb,enc_enb,enc_2_enb,dec_enb,pir_enc,
            heure_denc_h,lum_tewenty_percent,heure_denc_2_h,heure_denc_2_m,dec_2_enb
            ,heure_denc_m,detec_denc_m, lum_active,auto_or_fixe
            ,lum_start_fixe_zone_1_1,lum_start_fixe_zone_2_1,lum_start_fixe_zone_3_1,lum_start_fixe_zone_4_1,lum_fixe_start_zone_volt_1
            ,lum_fixe_start_h_1,lum_fixe_start_m_1
            ,lum_start_fixe_zone_1_2,lum_start_fixe_zone_2_2,lum_start_fixe_zone_3_2,lum_start_fixe_zone_4_2,lum_fixe_start_zone_volt_2
            ,lum_fixe_start_h_2,lum_fixe_start_m_2
            ,lum_end_fixe_zone_1_1,lum_end_fixe_zone_2_1,lum_end_fixe_zone_3_1,lum_end_fixe_zone_4_1,lum_end_fixe_zone_volt_1
            ,lum_fixe_end_h_1,lum_fixe_end_m_1
            ,lum_end_fixe_zone_1_2,lum_end_fixe_zone_2_2,lum_end_fixe_zone_3_2,lum_end_fixe_zone_4_2,lum_end_fixe_zone_volt_2
            ,lum_fixe_end_h_2,lum_fixe_end_m_2
            ,auto_val,lum_zone_1,lum_zone_2,lum_zone_3
            ,lum_zone_4,lum_zone_010v,cyc_enb,heure_p1_h,heure_p1_m,heure_p2_h,heure_p2_m,p1_temp,Cc_bet_times
            ,p2_temp,p3_temp,heure_p3_h,heure_p3_m,co2_notify,Summer_time,mqtt_time_sec,p4_temp,heure_p4_h,heure_p4_m;

    public static String profile_number,days,Zone_lum,Zone_veille,Zone_CC,SSID_modem,days_2,Zone_2_veille,Enb_CC,
            IP,MASK,GATE_WAY,DNS,enc_days,enc_2_days,enc_zones,enc_2_zones,pir_days,pir_zones,zones_lum_fixe;

    public static int co2_enb,co2_val,pir,ftp_enb,mqtt_enb,tz,ip_enb,state,co2_email_enb,co2_zone_enb,ftp_now_or_later,ftp_timeout,ftp_time_send_heure,ftp_time_send_minute,
            UDP_enb,UDP_idp4_idp6,UDP_port,Scene_state;
    public static String co2_zone,co2_email, adress_ftp,port_ftp,user_ftp,pass_ftp,adress_mqtt,client_id_ftp
            ,port_mqtt,user_mqtt,pass_mqtt,topic_mqtt,soustopic_mqtt,UDP_server;

    public static String Zone_1,Zone_2,Zone_3,Zone_4;

    public static JSONObject profil_object;

    public static Boolean thread_pass=false;

    DeviceControFragment deviceControFragment = null;
    ProfilsFragment profilsFragment = null;
    AmbiancesFragment ambiancesFragment = null;
    ScenesFragment scenesFragment = null;
    WifiProfileNonFragment wifiProfileNonFragment = null;

    int intPos = 0;

    public static String couleur_name1,couleur_name2,couleur_name3,couleur_name4;
    public static int stabilisation1,stabilisation2,stabilisation3,stabilisation4;
    public static int R1,R2,R3,R4;
    public static int V1,V2,V3,V4;
    public static int B1,B2,B3,B4;
    public static int Blanche1,Blanche2,Blanche3,Blanche4;
    public static String Zo1,Zo2,Zo3,Zo4;
    public static int L1,L2,L3,L4;

    public static boolean mReading_DATA;

    public static boolean write_profils,write_acceuil,write_access;

    static SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy à HH:mm:ss");

    public static String Favoris =
            "{\"couleur1\":[\"Ambiance1\",100,0,0,0,\"F\",50,50]," +
             "\"couleur2\":[\"Ambiance2\",100,0,0,0,\"F\",50,50]," +
             "\"couleur3\":[\"Ambiance3\",100,0,0,0,\"F\",50,50]," +
             "\"couleur4\":[\"Ambiance4\",100,0,0,0,\"F\",50,50]}";

    public static boolean DATA_READING;

    TextToSpeech tts;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        thread_pass=false;write_time=false;mReading_DATA=false;restart_Activity=false;
        restart_Scenes=false;Saving_scene=false;DATA_READING=false;Connecting_service=false;
        if (thread_attributes.isAlive())thread_attributes.interrupt();
        setContentView(R.layout.gatt_services_characteristics);
        Intent gattServiceIntent = new Intent(this, BluetoothLeService.class);
        bindService(gattServiceIntent, mServiceConnection, BIND_AUTO_CREATE);
        final Intent intent = getIntent();
        mDeviceName = intent.getStringExtra(EXTRAS_DEVICE_NAME);
        mDeviceAddress = intent.getStringExtra(EXTRAS_DEVICE_ADDRESS);
        getSupportActionBar().setTitle(mDeviceName);
        //getSupportActionBar().setTitle(Html.fromHtml("<font color=\"White\">" + mDeviceName + "</font>"));
        TextView versionName = findViewById(R.id.bienvenue);
        versionName.setText("Maestro™ - Lumi'Air V" + BuildConfig.VERSION_NAME);
        getSupportActionBar().setIcon(R.drawable.lumiair);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowTitleEnabled(true);
        getSupportActionBar().setDisplayUseLogoEnabled(true);
        getSupportActionBar().hide();

        Handler checking = new Handler();
        checking.postDelayed(new Runnable() {
            public void run() {
                accessing_the_project();
            }
        }, 1200);
    }


    public void ACCUIEL()
    {
        mReading_DATA=true;
        setContentView(R.layout.activity_main);
        ll_home =  findViewById(R.id.ll_home);
        ll_fon =  findViewById(R.id.ll_fon);
        ll_amb =  findViewById(R.id.ll_amb);
        ll_scene =  findViewById(R.id.ll_scene);
        ll_relg =  findViewById(R.id.ll_relg);
        deviceControFragment = new DeviceControFragment();
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.add(R.id.frame_container1, deviceControFragment);
        transaction.addToBackStack(null);
        transaction.commit();

        ll_home.setEnabled(false);
        ll_home.setBackgroundColor(Color.parseColor("#FF8C00"));
        ll_fon.setBackgroundColor(Color.TRANSPARENT);
        ll_amb.setBackgroundColor(Color.TRANSPARENT);
        ll_scene.setBackgroundColor(Color.TRANSPARENT);
        ll_relg.setBackgroundColor(Color.TRANSPARENT);

        Toast.makeText(getApplicationContext(),"Vous êtes connecté à Maestro!", Toast.LENGTH_SHORT).show();

        getSupportActionBar().show();

        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN|
                WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE|
                WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);

/*        askForSystemOverlayPermission();
        if (Settings.canDrawOverlays(this)) {
            startService(new Intent(this, FloatingWidgetService.class));
        } else {
            errorToast();
        }*/

        if(!ACCESS)
        {
            ll_fon.setEnabled(false);
            ll_fon.setBackgroundColor(Color.LTGRAY);
        }
/*        try {
            tts=new TextToSpeech(this, new TextToSpeech.OnInitListener() {

                @Override
                public void onInit(int status) {
                    // TODO Auto-generated method stub
                    if(status == TextToSpeech.SUCCESS)
                    {
                        int result=tts.setLanguage(Locale.FRANCE);
                        if(result==TextToSpeech.LANG_MISSING_DATA || result== TextToSpeech.LANG_NOT_SUPPORTED)
                        {
                            Log.e("error", "This Language is not supported");
                        }
                        else{
                            ConvertTextToSpeech();
                        }
                    }
                    else
                    {
                        Log.e("error", "Initilization Failed!");
                    }
                }
            });
        }catch (Throwable e)
        {
            e.printStackTrace();
        }*/


        ll_home.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (getSupportFragmentManager().getFragments() != null && getSupportFragmentManager().getFragments().size() > 0) {
                    for (int i = 0; i < getSupportFragmentManager().getFragments().size(); i++) {
                        Fragment mFragment = getSupportFragmentManager().getFragments().get(i);
                        if (mFragment != null) {
                            getSupportFragmentManager().beginTransaction().setCustomAnimations(R.anim.slide_from_right, R.anim.slide_to_left).remove(mFragment).commit();
                            deviceControFragment = new DeviceControFragment();
                            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
                            transaction.add(R.id.frame_container1, deviceControFragment);
                            transaction.addToBackStack(null);
                            transaction.commit();
                        }
                    }
                }

                ll_home.setBackgroundColor(Color.parseColor("#FF8C00"));
                ll_fon.setBackgroundColor(Color.TRANSPARENT);
                ll_amb.setBackgroundColor(Color.TRANSPARENT);
                ll_scene.setBackgroundColor(Color.TRANSPARENT);
                ll_relg.setBackgroundColor(Color.TRANSPARENT);
                ll_home.setEnabled(false);
                ll_fon.setEnabled(true);
                ll_amb.setEnabled(true);
                ll_scene.setEnabled(true);
                ll_relg.setEnabled(true);
                if(!ACCESS)
                {
                    ll_fon.setEnabled(false);
                    ll_fon.setBackgroundColor(Color.LTGRAY);
                }
                intPos = 0;

            }
        });

        ll_fon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


                if (!ll_fon.isEnabled())
                {
                    Toast.makeText(getApplicationContext(), "Votre access (USER) n'a pas d'accès sur \"fonctions\" , veuillez changer votre access pour l'accéder !", Toast.LENGTH_LONG).show();
                }


                if (getSupportFragmentManager().getFragments() != null && getSupportFragmentManager().getFragments().size() > 0) {
                    for (int i = 0; i < getSupportFragmentManager().getFragments().size(); i++) {
                        final Fragment mFragment = getSupportFragmentManager().getFragments().get(i);
                        if (mFragment != null) {
                            profilsFragment = new ProfilsFragment();
                            if (intPos > 1) {
                                getSupportFragmentManager().beginTransaction().setCustomAnimations(R.anim.slide_from_right, R.anim.slide_to_left).remove(mFragment).commit();
                                FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
                                transaction.add(R.id.frame_container1, profilsFragment);
                                transaction.addToBackStack(null);
                                transaction.commit();
                            } else {
                                FragmentTransaction transaction = getSupportFragmentManager().beginTransaction().setCustomAnimations(R.anim.slide_from_left, R.anim.slide_to_right);
                                transaction.add(R.id.frame_container1, profilsFragment);
                                transaction.addToBackStack(null);
                                transaction.commit();

                            }
                            Handler handler = new Handler();
                            handler.postDelayed(new Runnable() {
                                @SuppressLint("ResourceType")
                                public void run() {
                                    getSupportFragmentManager().beginTransaction().remove(mFragment).commit();
                                }
                            }, 100);

                        }
                    }
                }
                ll_home.setBackgroundColor(Color.TRANSPARENT);
                ll_fon.setBackgroundColor(Color.parseColor("#FF8C00"));
                ll_amb.setBackgroundColor(Color.TRANSPARENT);
                ll_scene.setBackgroundColor(Color.TRANSPARENT);
                ll_relg.setBackgroundColor(Color.TRANSPARENT);
                ll_home.setEnabled(true);
                ll_fon.setEnabled(false);
                ll_amb.setEnabled(true);
                ll_scene.setEnabled(true);
                ll_relg.setEnabled(true);
                if(!ACCESS)
                {
                    ll_fon.setEnabled(false);
                    ll_fon.setBackgroundColor(Color.LTGRAY);
                }
                intPos = 1;
            }
        });
        ll_amb.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (getSupportFragmentManager().getFragments() != null && getSupportFragmentManager().getFragments().size() > 0) {
                    for (int i = 0; i < getSupportFragmentManager().getFragments().size(); i++) {
                        final Fragment mFragment = getSupportFragmentManager().getFragments().get(i);
                        if (mFragment != null) {
                            ambiancesFragment = new AmbiancesFragment();
                            if (intPos > 2) {
                                getSupportFragmentManager().beginTransaction().setCustomAnimations(R.anim.slide_from_right, R.anim.slide_to_left).remove(mFragment).commit();
                                FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
                                transaction.add(R.id.frame_container1, ambiancesFragment);
                                transaction.addToBackStack(null);
                                transaction.commit();
                            } else {
                                FragmentTransaction transaction = getSupportFragmentManager().beginTransaction().setCustomAnimations(R.anim.slide_from_left, R.anim.slide_to_right);
                                transaction.add(R.id.frame_container1, ambiancesFragment);
                                transaction.addToBackStack(null);
                                transaction.commit();

                            }
                            Handler handler = new Handler();
                            handler.postDelayed(new Runnable() {
                                @SuppressLint("ResourceType")
                                public void run() {
                                    getSupportFragmentManager().beginTransaction().remove(mFragment).commit();
                                }
                            }, 100);

                        }
                    }
                }

                ll_home.setBackgroundColor(Color.TRANSPARENT);
                ll_fon.setBackgroundColor(Color.TRANSPARENT);
                ll_amb.setBackgroundColor(Color.parseColor("#FF8C00"));
                ll_scene.setBackgroundColor(Color.TRANSPARENT);
                ll_relg.setBackgroundColor(Color.TRANSPARENT);
                ll_home.setEnabled(true);
                ll_fon.setEnabled(true);
                ll_amb.setEnabled(false);
                ll_scene.setEnabled(true);
                ll_relg.setEnabled(true);
                if(!ACCESS)
                {
                    ll_fon.setEnabled(false);
                    ll_fon.setBackgroundColor(Color.LTGRAY);
                }
                intPos = 2;
            }
        });
        ll_scene.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getSupportFragmentManager().getFragments() != null && getSupportFragmentManager().getFragments().size() > 0) {
                    for (int i = 0; i < getSupportFragmentManager().getFragments().size(); i++) {
                        final Fragment mFragment = getSupportFragmentManager().getFragments().get(i);
                        if (mFragment != null) {
                            if (intPos > 3) {
                                getSupportFragmentManager().beginTransaction().setCustomAnimations(R.anim.slide_from_right, R.anim.slide_to_left).remove(mFragment).commit();
                                scenesFragment = new ScenesFragment();
                                FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
                                transaction.add(R.id.frame_container1, scenesFragment);
                                transaction.addToBackStack(null);
                                transaction.commit();
                            } else {
                                FragmentTransaction transaction = getSupportFragmentManager().beginTransaction().setCustomAnimations(R.anim.slide_from_left, R.anim.slide_to_right);
                                scenesFragment = new ScenesFragment();
                                transaction.add(R.id.frame_container1, scenesFragment);
                                transaction.addToBackStack(null);
                                transaction.commit();
                            }

                            Handler handler = new Handler();
                            handler.postDelayed(new Runnable() {
                                @SuppressLint("ResourceType")
                                public void run() {
                                    getSupportFragmentManager().beginTransaction().remove(mFragment).commit();
                                }
                            }, 100);
                        }
                    }
                }
                ll_home.setBackgroundColor(Color.TRANSPARENT);
                ll_fon.setBackgroundColor(Color.TRANSPARENT);
                ll_amb.setBackgroundColor(Color.TRANSPARENT);
                ll_scene.setBackgroundColor(Color.parseColor("#FF8C00"));
                ll_relg.setBackgroundColor(Color.TRANSPARENT);
                ll_home.setEnabled(true);
                ll_fon.setEnabled(true);
                ll_amb.setEnabled(true);
                ll_scene.setEnabled(false);
                ll_relg.setEnabled(true);
                if(!ACCESS)
                {
                    ll_fon.setEnabled(false);
                    ll_fon.setBackgroundColor(Color.LTGRAY);
                }
                intPos = 3;
                Handler handler = new Handler();
                handler.postDelayed(new Runnable() {
                    @SuppressLint("ResourceType")
                    public void run() {
                        Saving_scene=true;
                    }
                }, 2000);
            }
        });
        ll_relg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (getSupportFragmentManager().getFragments() != null && getSupportFragmentManager().getFragments().size() > 0) {
                    for (int i = 0; i < getSupportFragmentManager().getFragments().size(); i++) {
                        final Fragment mFragment = getSupportFragmentManager().getFragments().get(i);
                        if (mFragment != null) {
                            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction().setCustomAnimations(R.anim.slide_from_left, R.anim.slide_to_right);
                            wifiProfileNonFragment = new WifiProfileNonFragment();
                            transaction.add(R.id.frame_container1, wifiProfileNonFragment);
                            transaction.addToBackStack(null);
                            transaction.commit();
                            Handler handler = new Handler();
                            handler.postDelayed(new Runnable() {
                                @SuppressLint("ResourceType")
                                public void run() {
                                    getSupportFragmentManager().beginTransaction().remove(mFragment).commit();
                                }
                            }, 100);
                        }
                    }
                }
                ll_home.setBackgroundColor(Color.TRANSPARENT);
                ll_fon.setBackgroundColor(Color.TRANSPARENT);
                ll_amb.setBackgroundColor(Color.TRANSPARENT);
                ll_scene.setBackgroundColor(Color.TRANSPARENT);
                ll_relg.setBackgroundColor(Color.parseColor("#FF8C00"));
                ll_home.setEnabled(true);
                ll_fon.setEnabled(true);
                ll_amb.setEnabled(true);
                ll_scene.setEnabled(true);
                ll_relg.setEnabled(false);
                if(!ACCESS)
                {
                    ll_fon.setEnabled(false);
                    ll_fon.setBackgroundColor(Color.LTGRAY);
                }
                intPos = 4;
            }
        });
    }

    private BottomNavigationView.OnNavigationItemSelectedListener mOnNavigationItemSelectedListener
            = new BottomNavigationView.OnNavigationItemSelectedListener() {

        @Override
        public boolean onNavigationItemSelected(@NonNull MenuItem item) {
            switch (item.getItemId()) {
                case R.id.navigation_home:
                    clearStack();
                    return true;
                case R.id.navigation_edit:
                    ProfilsFragment profilsFragment = new ProfilsFragment();
                    replaceFragment(profilsFragment);
                    return true;
                case R.id.navigation_paint:
                    AmbiancesFragment ambiancesFragment = new AmbiancesFragment();
                    replaceFragment(ambiancesFragment);
                    return true;
                case R.id.navigation_movie:
                    ScenesFragment scenesFragment = new ScenesFragment();
                    replaceFragment(scenesFragment);
                    return true;
                case R.id.navigation_gear:
                    WifiProfileNonFragment wifiProfileNonFragment = new WifiProfileNonFragment();
                    replaceFragment(wifiProfileNonFragment);
                    return true;
            }
            return false;
        }

    };

    public MenuItem menuItem;

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.gatt_services_appcompat, menu);
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

    public void MAN_AUTO()
    {
        myswitch = menuItem.getActionView().findViewById(R.id.manorauto);
        if (state == 0) {
            myswitch.setChecked(false);
        } else {
            myswitch.setChecked(true);
        }
        myswitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                // do something based on isChecked
                if(Scene_state==1)
                {
                    Toast.makeText(getApplicationContext(), "Scènes est activé ! ", Toast.LENGTH_LONG).show();
                    state = 0;
                }else
                {
                    if(write_acceuil) {
                        if (isChecked) {
                            if (mConnected) {
                                Boolean check;
                                do {
                                    String switching = "{\"mode\":\"auto\"}";
                                    check = writecharacteristic(3, 0, switching);
                                    state = 1;
                                }
                                while (!check);
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
            }
        });
        if(ACCESS)
        {
            myswitch.setClickable(true);
        }else {
            myswitch.setClickable(false);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.menu_connect:
                Connection();
                return true;
            case R.id.menu_disconnect:
                Checking_Connection.cancel();
                active=false;
                DATA_READING=false;
                mBluetoothLeService.disconnect();
                thread_attributes.interrupt();
                unregisterReceiver(mGattUpdateReceiver);
                Intent i = new Intent(MainActivity.this, DeviceScanActivity.class);
                i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(i);
                return true;
            case android.R.id.home:
                onBackPressed();
                return true;
            case R.id.checking:
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void replaceFragment(Fragment newFragment) {
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        //ft.setCustomAnimations(R.anim.slide_from_left, R.anim.slide_to_right, R.anim.slide_from_right, R.anim.slide_to_left);
        ft.add(R.id.frame_container, newFragment)
                .commit();

    }

    public static String getDate(long timeStamp)
    {
        try
        {
            return sdf.format(new Date(timeStamp));
        }
        catch(Exception ex)
        {
            return "xx";
        }
    }

    public void clearStack() {
        //Here we are clearing back stack fragment entries
        int backStackEntry = getSupportFragmentManager().getBackStackEntryCount();
        if (backStackEntry > 0) {
            for (int i = 0; i < backStackEntry; i++) {
                getSupportFragmentManager().popBackStackImmediate();
            }
        }

        //Here we are removing all the fragment that are shown here
        if (getSupportFragmentManager().getFragments() != null && getSupportFragmentManager().getFragments().size() > 0) {
            for (int i = 0; i < getSupportFragmentManager().getFragments().size(); i++) {
                Fragment mFragment = getSupportFragmentManager().getFragments().get(i);
                if (mFragment != null) {
                    getSupportFragmentManager().beginTransaction().remove(mFragment).commit();
                }
            }
        }
    }

    private List<Fragment> getFragments() {

        List<Fragment> fList = new ArrayList<Fragment>();

        fList.add(new DeviceControFragment());
        fList.add(new ProfilsFragment());
        fList.add(new AmbiancesFragment());
        fList.add(new ScenesFragment());
        fList.add(new WifiProfileNonFragment());

        return fList;

    }

    private static final class PageAdapter extends FragmentStatePagerAdapter {
        private List<Fragment> fragments;

        public PageAdapter(FragmentManager fragmentManager, List<Fragment> fragments) {
            super(fragmentManager);
            this.fragments = fragments;
        }

        @Override
        public Fragment getItem(int position) {
            return this.fragments.get(position);
        }

        @Override
        public int getCount() {
            return 5;
        }

    }

    public void accessing_the_project()
    {
        // the project MAESTRO
        dataserveur = false;datacouleur =false;dataprofile =true;active=true;
        thread_attributes.start();Checking_Connection.start();
    }

    @Override
    public void onBackPressed() {
        //super.onBackPressed();
        if(Acceuil_isactive)
        {
            final AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
            builder.setMessage("Souhaitez-vous quitter "+mDeviceName+" ?")
                    .setCancelable(true)
                    .setTitle("Quitter")
                    .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.cancel();
                        }
                    })
                    .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                        public void onClick(final DialogInterface dialog, final int id) {
                            Checking_Connection.cancel();
                            active=false;
                            DATA_READING=false;
                            mBluetoothLeService.disconnect();
                            thread_attributes.interrupt();
                            //unregisterReceiver(mGattUpdateReceiver);
                            Intent i = new Intent(MainActivity.this, DeviceScanActivity.class);
                            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                            dialog.cancel();
                            startActivity(i);
                        }
                    });
            final AlertDialog alert = builder.create();
            alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
            alert.show();
        }else
        {
            ll_home.performClick();
        }
    }

    boolean Read_profile,Read_color,Read_expert,Read_capteurs;

    int hours,minutes,seconds;

    Thread thread_attributes = new Thread() {
        @Override
        public void run() {
            if (Looper.myLooper() == null)
            {
                Looper.prepare();
            }
            new CountDownTimer(1000, 1000) {
                public void onTick(long l) {}
                public void onFinish() {
                    if (thread_attributes.isInterrupted()) {
                        // We've been interrupted: no more crunching.
                        return;
                    }
                    if (thread_pass) {
                        thread_attributes.interrupt();
                    }
                    if (isActive()) {
                        // Create a Runnable to run on the UI Thread for reading.
                        if (Thread.currentThread().isInterrupted()) {
                            Thread.currentThread().interrupt();
                        }
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (compter==1)
                                {
                                    dataprofile =false;
                                    dataserveur=true;
                                }
                                if(compter==2)
                                {
                                    dataserveur=false;
                                    datacouleur=true;
                                }
                                if(compter==3)
                                {
                                    datacouleur=false;
                                }
                                try {
                                    if (dataprofile)
                                    {
                                        bleReadWrite = false;
                                        Read_profile=readcharacteristic(SERVICE_READ, CHAR_READ_PROFILS);
                                        Log.i(TAG, "Read profile = "+Read_profile);
                                    }
                                    else if (dataserveur)
                                    {
                                        bleReadWrite = false;
                                        Read_color=readcharacteristic(SERVICE_READ, CHAR_READ_ADVANCED);
                                        Log.i(TAG, "Read color = "+Read_color);
                                    } else if (datacouleur)
                                    {
                                        bleReadWrite = false;
                                        Read_expert=readcharacteristic(SERVICE_READ, CHAR_READ_EXPERT);
                                        Log.i(TAG, "Read expert = "+Read_expert);
                                    }
                                    else {
                                        if(datacapteur)
                                        {
                                            Read_capteurs=readcharacteristic(SERVICE_READ, CHAR_READ_CAPTERS);
                                        }else
                                        if (Read_profile&Read_color&Read_expert)
                                        {
                                            long currentTime = Calendar.getInstance().getTimeInMillis()/1000;
                                            int mtimezone= TimeZone.getDefault().getRawOffset()/1000;
                                            String trame_time="{\"Time\":["+currentTime+","+mtimezone+"]}";
                                            Log.i(TAG, "ssid = " + SSID_modem);
                                            if (SSID_modem.equals("null"))
                                            {
                                                if (mConnected) {
                                                    boolean check;
                                                    do {
                                                        check=writecharacteristic(SERVICE_WRITE,CHAR_WRITE_SYSTEM,trame_time);
                                                        if (!mConnected) { break; }
                                                    } while (!check);
                                                }
                                                Log.i(TAG, "Writing to esp32 to set time = " + trame_time);
                                            }
                                            else
                                            {
                                                setting_time();
                                            }
                                            ACCUIEL();
                                            datacapteur=true;
                                            Read_profile=false;
                                            Read_color=false;
                                            Read_expert=false;
                                        }else
                                        {
                                            initilise();
                                        }
                                    }
                                }catch (Throwable t)
                                {
                                    t.printStackTrace();
                                    initilise();
                                }
                                hours = compter / 3600;
                                minutes = (compter % 3600) / 60;
                                seconds = compter % 60;
                                time = String.format("%02d:%02d:%02d", hours, minutes, seconds);
                                compter++;
                                if (compter>=3)
                                {
                                    registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter());
                                }
                                if (restart_Activity)
                                {
                                    restart_ACESSS();
                                }
                                if (restart_Scenes)
                                {
                                    restart_scenes();
                                }
                            }
                        });
                        // Block this thread for 2 millis seconds.
                        try {
                            Thread.sleep(200);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                    }
                    if(mConnected)
                    {
                        DATA_READING=true;
                    }
                    if(speech_test)
                    {
                        speech_test=false;
                        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);

                        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, "fr-FR");

                        try {

                            startActivityForResult(intent, RESULT_SPEECH);
                            Log.i("SPEECH","the text in speech is null !");
                            //txtText.setText("");
                        } catch (
                                ActivityNotFoundException a) {
                            Toast t = Toast.makeText(getApplicationContext(),
                                    "Opps! Your device doesn't support Speech to Text",
                                    Toast.LENGTH_SHORT);
                            t.show();
                        }
                    }
                    start();
                }
            }.start();
            Looper.loop();
        }
    };

    protected static final int RESULT_SPEECH = 1;

    private void askForSystemOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {

            //If the draw over permission is not available open the settings screen
            //to grant the permission.
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:" + getPackageName()));
            startActivityForResult(intent, DRAW_OVER_OTHER_APP_PERMISSION);
        }
    }

    String our_text_speech;
    private void ConvertTextToSpeech() {
        // TODO Auto-generated method stub
        if(our_text_speech==null||"".equals(our_text_speech))
        {
            our_text_speech = "Bienvenue sur l'application Lumi'air ";
            tts.speak(our_text_speech,TextToSpeech.QUEUE_FLUSH,null,null);
        }else
        {
            tts.speak(our_text_speech+" a été demandé",TextToSpeech.QUEUE_FLUSH,null,null);
        }
    }

    private static final int DRAW_OVER_OTHER_APP_PERMISSION = 123;

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == DRAW_OVER_OTHER_APP_PERMISSION) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!Settings.canDrawOverlays(this)) {
                    //Permission is not available. Display error text.
                    errorToast();
                    //finish();
                }
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data);
            switch (requestCode) {
                case RESULT_SPEECH: {
                    if (resultCode == RESULT_OK && null != data) {

                        ArrayList<String> text = data
                                .getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);

                        Log.i("SPEECH","the text in speech is : "+text.get(0));
                        our_text_speech=text.get(0);
                        ConvertTextToSpeech();
                        if(our_text_speech.contains("fonction"))
                        {
                            ll_fon.performClick();
                        }
                        if(our_text_speech.contains("éteins zone 1")) {
                            if (mConnected) {
                                String Power = "{\"light\":[1,1,1]}";
                                Boolean check;
                                do {

                                    check = writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, Power);
                                } while (!check);
                                Toast.makeText(this, "étiendre zone 1", Toast.LENGTH_LONG).show();
                            } else {
                                Toast.makeText(this, "pas de connexion !", Toast.LENGTH_LONG).show();
                            }
                        }
                        if(our_text_speech.contains("allume zone 1")) {
                            if (mConnected) {
                                String Power = "{\"light\":[1,0,1]}";
                                Boolean check;
                                do {

                                    check = writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, Power);
                                } while (!check);
                                Toast.makeText(this, "allumage zone 1", Toast.LENGTH_LONG).show();
                            } else {
                                Toast.makeText(this, "pas de connexion !", Toast.LENGTH_LONG).show();
                            }
                        }
                        if(our_text_speech.contains("mode manuel"))
                        {
                            if (mConnected) {
                                Boolean check;
                                do {
                                    String switching = "{\"mode\":\"manu\"}";
                                    state = 0;
                                    check = writecharacteristic(3, 0, switching);
                                }
                                while (!check);
                                Toast.makeText(this, "etat manuel !", Toast.LENGTH_LONG).show();
                            }else
                            {
                                Toast.makeText(this, "pas de connexion !", Toast.LENGTH_LONG).show();
                            }

                        }
                        if(our_text_speech.contains("mode auto"))
                        {
                            if (mConnected) {
                                Boolean check;
                                do {
                                    String switching = "{\"mode\":\"auto\"}";
                                    state = 1;
                                    check = writecharacteristic(3, 0, switching);
                                }
                                while (!check);
                                Toast.makeText(this, "etat automatique !", Toast.LENGTH_LONG).show();
                            }else
                            {
                                Toast.makeText(this, "pas de connexion !", Toast.LENGTH_LONG).show();
                            }
                        }
                        if(our_text_speech.contains("aide"))
                        {
                            if (mConnected) {
                                Uri uriUrl = Uri.parse("https://delitech.eu/content/8-manuel-utilisation-lumiair-mobile");
                                Intent launchBrowser = new Intent(Intent.ACTION_VIEW, uriUrl);
                                startActivity(launchBrowser);
                            }else
                            {
                                Toast.makeText(this, "pas de connexion !", Toast.LENGTH_LONG).show();
                            }
                        }
                        if(our_text_speech.contains("connexion"))
                        {
                            Connection();
                        }
                        if(our_text_speech.contains("envoie email"))
                        {
                            if (mConnected) {
                                Boolean check = false;
                                do {
                                    check=writecharacteristic(3, 0, "{\"test\":\"" + co2_email + "\"}");
                                }
                                while (!check);
                            }
                        }
                        //txtText.setText(text.get(0));
                    }
                    break;
                }
            }
        }
    }

    private void errorToast() {
        Toast.makeText(this, "Dessinez sur d'autres autorisations d'application non disponibles. Impossible de démarrer l'application sans l'autorisation.", Toast.LENGTH_LONG).show();
    }

    public void initilise()
    {
        Toast.makeText(getApplicationContext(), "Problème de connection réssayer ! ", Toast.LENGTH_LONG).show();
        Checking_Connection.cancel();
        active=false;
        DATA_READING=false;
        mBluetoothLeService.disconnect();
        thread_attributes.interrupt();
        //unregisterReceiver(mGattUpdateReceiver);
        Intent i = new Intent(MainActivity.this, DeviceScanActivity.class);
        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(i);
    }

    public void setting_time()
    {
        String x = TimeZone.getDefault().getDisplayName(false,TimeZone.SHORT, Locale.getDefault());
        // Current timezone and date
        TimeZone timeZone = TimeZone.getDefault();
        //boolean usedaylight=false;
        boolean observedaylight=false;
        Date nowDate = new Date();
        // Daylight Saving time
        if (timeZone.useDaylightTime()) {
            // DST is used
            // save that now we are in DST mode
            if (timeZone.inDaylightTime(nowDate)) {
                // Now you are in use of DST mode
                observedaylight=true;
            } else {
                // DST mode is not used for this timezone
                observedaylight=false;
            }
        }
        int summer_time = observedaylight ? 1 : 0;
        //Toast.makeText(getBaseContext(), "observedaylight = "+observedaylight+", usedaylight = "+usedaylight, Toast.LENGTH_LONG).show();
        String zone_and_summer="{\"tz\":\""+x+"\",\"summer\":"+summer_time+"}";
        writecharacteristic(3, 0, zone_and_summer);
        active=true;
    }
    public void restart_ACESSS()
    {
        mReading_DATA=true;
        ll_home.performClick();
        restart_Activity=false;
    }
    public void restart_scenes()
    {
        mReading_DATA=true;
        ll_scene.setEnabled(true);
        ll_scene.performClick();
        ll_scene.setEnabled(false);
        Saving_scene=false;
    }

    BluetoothGattCharacteristic charac_read;
    int charaProp_read;
    boolean read;

    public boolean readcharacteristic (int i ,int j)
    {
        read =false;
        if (mBluetoothLeService!=null)
        {
            if (!bleReadWrite) {
                try {
                    charac_read = mGattCharacteristics.get(i).get(j);
                    charaProp_read = charac_read.getProperties();
                    if ((charaProp_read | BluetoothGattCharacteristic.PROPERTY_READ) > 0) {
                        if (mNotifyCharacteristic != null) {
                            mBluetoothLeService.setCharacteristicNotification(mNotifyCharacteristic, false);
                            mNotifyCharacteristic = null;
                        }
                        read = mBluetoothLeService.readCharacteristic(charac_read);

                    }
                    if ((charaProp_read | BluetoothGattCharacteristic.PROPERTY_NOTIFY) > 0) {
                        mNotifyCharacteristic = charac_read;
                        mBluetoothLeService.setCharacteristicNotification(charac_read, true);
                    }
                } catch (Throwable t) {
                    t.printStackTrace();
                    return false;
                }
            }
        }
        return read;
    }

    public static boolean Connecting_service;
    public void Connection()
    {
        try {
            Log.d(TAG, "Connect request result=" + mBluetoothLeService.connect(mDeviceAddress));
        }catch (Throwable t)
        {
            t.printStackTrace();
        }
    }
    CountDownTimer Checking_Connection= new CountDownTimer(1000,1000) {
        @Override
        public void onTick(long millisUntilFinished) {
        }
        @Override
        public void onFinish() {
            if(mConnectionState==STATE_DISCONNECTED) {
                Connection();
            }
            start();
        }
    };

    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver(mGattUpdateReceiver, makeGattUpdateIntentFilter());
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN|
                WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE|
                WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);

        active=true;
    }
    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "we will pause the App for now !");
        // To prevent starting the service if the required permission is NOT granted.
        /*if (Settings.canDrawOverlays(this)) {
            startService(new Intent(getApplicationContext(), FloatingWidgetService.class).putExtra("activity_background", true));
            finish();
        } else {
            errorToast();
        }*/
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unbindService(mServiceConnection);
        mBluetoothLeService = null;
        stopService(new Intent(this, FloatingWidgetService.class));
        thread_attributes.interrupt();
    }
    BluetoothGattCharacteristic charac_write;
    int charaProp_write;
    byte[] values_write;
    boolean write;
    public boolean writecharacteristic(int i,int j, String data){
        write=false;
        bleReadWrite=true;
        try {
            charac_write = mGattCharacteristics.get(i).get(j);
            charaProp_write = charac_write.getProperties();
            values_write = data.getBytes();
            charac_write.setValue(values_write);
            charac_write.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
            if ((charaProp_write | BluetoothGattCharacteristic.PROPERTY_WRITE) > 0) {
                if (mNotifyCharacteristic != null) {
                    mBluetoothLeService.setCharacteristicNotification(mNotifyCharacteristic, false);
                    mNotifyCharacteristic = null;
                }
                write = mBluetoothLeService.writeCharacteristic(charac_write);
            }
            if ((charaProp_write | BluetoothGattCharacteristic.PROPERTY_NOTIFY) > 0) {
                mNotifyCharacteristic = charac_write;
                mBluetoothLeService.setCharacteristicNotification(charac_write, true);
                if (thread_attributes.isInterrupted()) {
                    thread_attributes.run();
                }
            }
            bleReadWrite = false;
        }catch (Throwable t) {
            return false;
        }

        return write;
    }

    public static void pause (int x)
    {
        try {
            Thread.sleep(x); //pause de 1000ms (1s)
        } catch(InterruptedException ex) {
            ex.printStackTrace();
        }
    }

    // Demonstrates how to iterate through the supported GATT Services/Characteristics.
    // In this sample, we populate the data structure that is bound to the ExpandableListView
    // on the UI.

    private void displayGattServices(List<BluetoothGattService> gattServices) {
        if (gattServices == null) return;

        ArrayList<HashMap<String, String>> gattServiceData = new ArrayList<>();
        ArrayList<ArrayList<HashMap<String, String>>> gattCharacteristicData = new ArrayList<>();
        mGattCharacteristics = new ArrayList<>();

        // Loops through available GATT Services.
        for (BluetoothGattService gattService : gattServices) {
            HashMap<String, String> currentServiceData = new HashMap<>();
            gattServiceData.add(currentServiceData);

            ArrayList<HashMap<String, String>> gattCharacteristicGroupData = new ArrayList<>();
            List<BluetoothGattCharacteristic> gattCharacteristics = gattService.getCharacteristics();
            ArrayList<BluetoothGattCharacteristic> charas = new ArrayList<>();

            // Loops through available Characteristics.
            for (BluetoothGattCharacteristic gattCharacteristic : gattCharacteristics) {
                charas.add(gattCharacteristic);
                HashMap<String, String> currentCharaData = new HashMap<>();
                gattCharacteristicGroupData.add(currentCharaData);
            }
            mGattCharacteristics.add(charas);
            gattCharacteristicData.add(gattCharacteristicGroupData);

        }
        BluetoothGattCharacteristic charac_write;
        byte[] values_write;
        if(!change_mode)
        {
            while(MTU_CHECKED)
            {
                try {
                    boolean write;
                    charac_write = mGattCharacteristics.get(3).get(1);
                    values_write = ("{\"pass\":\"deliled\",\"app_ver\":"+(int)(Float.valueOf(BuildConfig.VERSION_NAME)*10)+"}").getBytes();
                    charac_write.setValue(values_write);
                    charac_write.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
                    write=mBluetoothLeService.writeCharacteristic(charac_write);
                    if(write)
                    {
                        break;
                    }
                }catch (NullPointerException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private IntentFilter makeGattUpdateIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_CONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_DISCONNECTED);
        intentFilter.addAction(BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED);
        intentFilter.addAction(BluetoothLeService.ACTION_DATA_AVAILABLE);
        return intentFilter;
    }

    // Handles various events fired by the Service.
    // ACTION_GATT_CONNECTED: connected to a GATT server.
    // ACTION_GATT_DISCONNECTED: disconnected from a GATT server.
    // ACTION_GATT_SERVICES_DISCOVERED: discovered GATT services.
    // ACTION_DATA_AVAILABLE: received data from the device.  This can be a result of read
    //                        or notification operations.
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
            } else if (BluetoothLeService.ACTION_GATT_SERVICES_DISCOVERED.equals(action)) {
                // Show all the supported services and characteristics on the user interface.
                if (mConnected)
                {
                    try{
                        displayGattServices(mBluetoothLeService.getSupportedGattServices());
                    }catch (Throwable e)
                    {
                        onBackPressed();
                        e.printStackTrace();
                    }
                }
            } else if (BluetoothLeService.ACTION_DATA_AVAILABLE.equals(action)) {
                if (dataprofile) {
                    Displaydata(intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
                }else if (dataserveur){
                    displaydata(intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
                }else if (datacouleur){
                    DisplayData(intent.getStringExtra(BluetoothLeService.EXTRA_DATA));
                } else {
                    if (mConnected)
                    {
                        BluetoothGattCharacteristic characteristic = mGattCharacteristics.get(2).get(0);
                        try{
                            displayData(characteristic.getValue());
                        }catch (Throwable s )
                        {
                            s.printStackTrace();
                        }

                    }
                }
            }
        }
    };
    // Code to manage Service lifecycle.
    private final ServiceConnection mServiceConnection = new ServiceConnection() {

        @Override
        public void onServiceConnected(ComponentName componentName, IBinder service) {
            mBluetoothLeService = ((BluetoothLeService.LocalBinder) service).getService();
            if (!mBluetoothLeService.initialize()) {
                Log.e(TAG, "Unable to initialize Bluetooth");
                finish();
            }
            // Automatically connects to the device upon successful start-up initialization.
            do
            {
                mConnected=mBluetoothLeService.connect(mDeviceAddress);
            }
            while(!mConnected);
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            mBluetoothLeService = null;
        }
    };

    private void displayData(byte data[]) {
        //reading data
        Udata_time = ByteBuffer.wrap(Arrays.copyOfRange(data, 0, 4)).order(ByteOrder.LITTLE_ENDIAN).getInt();
        Udata_ldt = ByteBuffer.wrap(Arrays.copyOfRange(data, 4, 8)).order(ByteOrder.LITTLE_ENDIAN).getInt();
        Udata_temp = ByteBuffer.wrap(Arrays.copyOfRange(data, 8, 16)).order(ByteOrder.LITTLE_ENDIAN).getDouble();
        Udata_humidity = ByteBuffer.wrap(Arrays.copyOfRange(data, 16, 24)).order(ByteOrder.LITTLE_ENDIAN).getDouble();
        Udata_als = ByteBuffer.wrap(Arrays.copyOfRange(data, 24, 26)).order(ByteOrder.LITTLE_ENDIAN).getShort();
        Udata_co2l = ByteBuffer.wrap(Arrays.copyOfRange(data, 26, 28)).order(ByteOrder.LITTLE_ENDIAN).getShort();
        Udata_tvoc = ByteBuffer.wrap(Arrays.copyOfRange(data, 28, 30)).order(ByteOrder.LITTLE_ENDIAN).getShort();
        Udata_aq_status = data[30];
        indice_confinent = data[31];
        Update_info = data[32];
        Udata_lum_zone_1 = data[33];
        Udata_lum_zone_2 = data[34];
        Udata_lum_zone_3 = data[35];
        Udata_lum_zone_4 = data[36];
        Udata_lum_zone_010v = data[37];
        state = data[38];
        Udata_ota = data[39];
        Udata_ota_checking = data[40];
        Udata_scene_number= data[41];
        the_Notifications();
    }
    int OTA_Maestro=0;
    public void the_Notifications()
    {
        //test the data
        if (Udata_ota_checking==1)
        {
            OTA_Maestro++;
            if (OTA_Maestro==20)
            {
                final AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
                builder.setMessage("Une nouvelle version du logiciel HuBBox est disponible, veuillez le mettre à jour !")
                        .setCancelable(true)
                        .setTitle("Mise à jour")
                        .setNeutralButton("OK", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                dialog.cancel();
                            }
                        });
                final AlertDialog alert = builder.create();
                alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
                alert.show();
                Notification_Update(getClass(),
                        getApplicationContext(),
                        "Mise à jour du HuBBox est disponible !",
                        "Une nouvelle version du logiciel HuBBox est disponible, veuillez le mettre à jour !");
            }
        }
        else
        {
            OTA_Maestro=0;
        }
        if(write_time)
        {
            time_esp();
        }
        if (co2_notify==1&&Udata_co2l>=co2_val)
        {
            createNotification(getClass(),
                    getApplicationContext(),
                    "Niveau de CO2 élévé",
                    "Le niveau de CO2 maximum programmé à été dépassé, pensez à renouveler l'air de votre pièce.");
        }
        write_acceuil=false;
        Log.i("compter","reading the DATA 2 !");
        if (state==0)
        {
            myswitch.setChecked(false);
        }
        else
        {
            myswitch.setChecked(true);
        }
        write_acceuil=true;

    }
    private void Displaydata(String data)
    {
        try {
            JSONObject custom = new JSONObject(data);
            profile_number =custom.getString("profile_id");
            profil_object =custom.getJSONObject("PROFILE_1");
            JSONArray profile = profil_object.getJSONArray("pdata");
            enc_enb=profile.getInt(0);
            enc_days=profile.getString(1);
            enc_zones=profile.getString(2);
            heure_enc_time_h = profile.getInt(3);
            heure_enc_time_m = profile.getInt(4);
            enc_2_enb=profile.getInt(5);
            enc_2_days=profile.getString(6);
            enc_2_zones=profile.getString(7);
            heure_enc_2_time_h = profile.getInt(8);
            heure_enc_2_time_m = profile.getInt(9);
            dec_enb=profile.getInt(10);
            days=profile.getString(11);
            Zone_veille=profile.getString(12);
            heure_denc_h = profile.getInt(13);
            heure_denc_m = profile.getInt(14);
            dec_2_enb=profile.getInt(15);
            days_2=profile.getString(16);
            Zone_2_veille=profile.getString(17);
            heure_denc_2_h = profile.getInt(18);
            heure_denc_2_m = profile.getInt(19);
            JSONArray lum = profil_object.getJSONArray("lum");
            lum_active = lum.getInt(0);
            auto_val = lum.getInt(1);
            Zone_lum = lum.getString(2);
            lum_zone_1=lum.getInt(3);
            lum_zone_2=lum.getInt(4);
            lum_zone_3=lum.getInt(5);
            lum_zone_4=lum.getInt(6);
            lum_zone_010v=lum.getInt(7);
            lum_tewenty_percent=lum.getInt(8);
            auto_or_fixe=lum.getInt(9);
            zones_lum_fixe=lum.getString(10);
            lum_start_fixe_zone_1_1=lum.getInt(11);
            lum_start_fixe_zone_2_1=lum.getInt(12);
            lum_start_fixe_zone_3_1=lum.getInt(13);
            lum_start_fixe_zone_4_1=lum.getInt(14);
            lum_fixe_start_zone_volt_1=lum.getInt(15);
            lum_start_fixe_zone_1_2=lum.getInt(16);
            lum_start_fixe_zone_2_2=lum.getInt(17);
            lum_start_fixe_zone_3_2=lum.getInt(18);
            lum_start_fixe_zone_4_2=lum.getInt(19);
            lum_fixe_start_zone_volt_2=lum.getInt(20);
            lum_fixe_start_h_1=lum.getInt(21);
            lum_fixe_start_m_1=lum.getInt(22);
            lum_fixe_start_h_2=lum.getInt(23);
            lum_fixe_start_m_2=lum.getInt(24);
            lum_fixe_end_h_1=lum.getInt(25);
            lum_fixe_end_m_1=lum.getInt(26);
            lum_fixe_end_h_2=lum.getInt(27);
            lum_fixe_end_m_2=lum.getInt(28);
            lum_end_fixe_zone_1_1=lum.getInt(29);
            lum_end_fixe_zone_2_1=lum.getInt(30);
            lum_end_fixe_zone_3_1=lum.getInt(31);
            lum_end_fixe_zone_4_1=lum.getInt(32);
            lum_end_fixe_zone_volt_1=lum.getInt(33);
            lum_end_fixe_zone_1_2=lum.getInt(34);
            lum_end_fixe_zone_2_2=lum.getInt(35);
            lum_end_fixe_zone_3_2=lum.getInt(36);
            lum_end_fixe_zone_4_2=lum.getInt(37);
            lum_end_fixe_zone_volt_2=lum.getInt(38);
            JSONArray veille = profil_object.getJSONArray("veille");
            veille_enb = veille.getInt(0);
            pir_enc=veille.getInt(1);
            detec_denc_m = veille.getInt(2);
            pir_days=veille.getString(3);
            pir_zones=veille.getString(4);
            JSONArray cycle = profil_object.getJSONArray("cycle");
            cyc_enb = cycle.getInt(0);
            Zone_CC=cycle.getString(1);
            Enb_CC=cycle.getString(2);
            Cc_bet_times=cycle.getInt(3);
            heure_p1_h = cycle.getInt(4);
            heure_p1_m = cycle.getInt(5);
            p1_temp = cycle.getInt(6);
            heure_p2_h = cycle.getInt(7);
            heure_p2_m = cycle.getInt(8);
            p2_temp = cycle.getInt(9);
            heure_p3_h = cycle.getInt(10);
            heure_p3_m = cycle.getInt(11);
            p3_temp = cycle.getInt(12);
            heure_p4_h = cycle.getInt(13);
            heure_p4_m = cycle.getInt(14);
            p4_temp = cycle.getInt(15);
        }
        catch (Throwable t)
        {
            Log.e("My App", "Could not parse malformed JSON 1 : " + data);
            profile_number="Bureau";enc_enb=0;enc_days="0";enc_zones="0";heure_enc_time_h=0;heure_enc_time_m=0;enc_2_enb=0;enc_2_days="0";enc_2_zones="0";heure_enc_2_time_h=0;heure_enc_2_time_m=0;
            dec_enb=0;days="0";Zone_veille="0";heure_denc_h=0;heure_denc_m=0;dec_2_enb=0;days_2="0";Zone_2_veille="0";heure_denc_2_h=0;heure_denc_2_m=0;lum_active=0;auto_val=0;Zone_lum="0";
            lum_zone_1=0;lum_zone_2=0;lum_zone_3=0;lum_zone_4=0;lum_zone_010v=0;lum_tewenty_percent=0;auto_or_fixe=0;zones_lum_fixe="0";lum_start_fixe_zone_1_1=0;lum_start_fixe_zone_2_1=0;
            lum_start_fixe_zone_3_1=0;lum_start_fixe_zone_4_1=0;lum_fixe_start_zone_volt_1=0;lum_start_fixe_zone_1_2=0;lum_start_fixe_zone_2_2=0;lum_start_fixe_zone_3_2=0;lum_start_fixe_zone_4_2=0;
            lum_fixe_start_zone_volt_2=0;lum_fixe_start_h_1=0;lum_fixe_start_m_1=0;lum_fixe_start_h_2=0;lum_fixe_start_m_2=0;lum_fixe_end_h_1=0;lum_fixe_end_m_1=0;lum_fixe_end_h_2=0;
            lum_fixe_end_m_2=0;lum_end_fixe_zone_1_1=0;lum_end_fixe_zone_2_1=0;lum_end_fixe_zone_3_1=0;lum_end_fixe_zone_4_1=0;lum_end_fixe_zone_volt_1=0;lum_end_fixe_zone_1_2=0;lum_end_fixe_zone_2_2=0;
            lum_end_fixe_zone_3_2=0;lum_end_fixe_zone_4_2=0;lum_end_fixe_zone_volt_2=0;veille_enb=0;pir_enc=0;detec_denc_m=0;pir_days="0";pir_zones="0";cyc_enb=0;Zone_CC="0";Enb_CC="0";Cc_bet_times=0;
            heure_p1_h=0;heure_p1_m=0;p1_temp=0;heure_p2_h=0;heure_p2_m=0;p2_temp=0;heure_p3_h=0;heure_p3_m=0;p3_temp=0;heure_p4_h=0;heure_p4_m=0;p4_temp=0;
        }
    }

    private void displaydata(String data)
    {
        try
        {
            JSONObject avancee = new JSONObject(data);
            Summer_time=avancee.getInt("summer");
            pir = avancee.getInt("pir");
            tz = avancee.getInt("tz");
            JSONArray ftp = avancee.getJSONArray("ftp");
            ftp_enb = ftp.getInt(0);
            adress_ftp = ftp.getString(1);
            port_ftp = ftp.getString(2);
            user_ftp = ftp.getString(3);
            pass_ftp = ftp.getString(4);
            client_id_ftp=ftp.getString(5);
            ftp_now_or_later=ftp.getInt(6);
            ftp_timeout=ftp.getInt(7);
            ftp_time_send_heure=ftp.getInt(8);
            ftp_time_send_minute=ftp.getInt(9);
            JSONArray mqtt = avancee.getJSONArray("mqtt");
            mqtt_enb = mqtt.getInt(0);
            adress_mqtt= mqtt.getString(1);
            port_mqtt= mqtt.getString(2);
            user_mqtt = mqtt.getString(3);
            pass_mqtt = mqtt.getString(4);
            topic_mqtt= mqtt.getString(5);
            soustopic_mqtt=mqtt.getString(6);
            mqtt_time_sec=mqtt.getInt(7);
        }
        catch (Throwable t)
        {
            Log.e("My App", "Could not parse malformed JSON 2 : " + data );
            Summer_time=0;pir=500;tz=0;ftp_enb=0;adress_ftp="ftpserver";port_ftp="21";user_ftp="ftpuser";
            pass_ftp="ftppassword";client_id_ftp="client_1";ftp_now_or_later=0;ftp_timeout=0;ftp_time_send_heure=0;
            ftp_time_send_minute=0;mqtt_enb=0;adress_mqtt="mqttserver";port_mqtt="80";user_mqtt="mqttuser";pass_mqtt="mqttpassword";
            topic_mqtt="mqtttopic";soustopic_mqtt="all";mqtt_time_sec=0;
        }
    }

    private void DisplayData(String data)
    {
        try
        {
            JSONObject colors = new JSONObject(data);
            SSID_modem = colors.getString("modem");
            JSONArray co2 = colors.getJSONArray("co2");
            co2_enb = co2.getInt(0);
            co2_email_enb=co2.getInt(1);
            co2_email = co2.getString(2);
            co2_notify=co2.getInt(3);
            co2_zone_enb=co2.getInt(4);
            co2_zone = co2.getString(5);
            co2_val = co2.getInt(6);
            Scene_state=colors.getInt("scenes");
            JSONArray ip_static = colors.getJSONArray("IP_STATIC");
            ip_enb = ip_static.getInt(0);
            IP = ip_static.getString(1);
            MASK = ip_static.getString(2);
            GATE_WAY = ip_static.getString(3);
            DNS = ip_static.getString(4);
            JSONArray udp = colors.getJSONArray("UDP");
            UDP_enb=udp.getInt(0);
            UDP_idp4_idp6=udp.getInt(1);
            UDP_server=udp.getString(2);
            UDP_port=udp.getInt(3);
            Zone_1=colors.getString("Z_1");
            Zone_2=colors.getString("Z_2");
            Zone_3=colors.getString("Z_3");
            Zone_4=colors.getString("Z_4");
            //Log.i("My App",  data );
        }
        catch (Throwable t)
        {
            Log.e("My App", "Could not parse malformed JSON 3 : " + data );
            SSID_modem="null";co2_enb=0;co2_email_enb=0;co2_email="exemple@mail.com";
            co2_notify=0;co2_zone="0";co2_zone_enb=0;co2_val=1500;ip_enb=0;
            IP="192.168.1.22";MASK="255.255.255.0";GATE_WAY="192.168.1.254";DNS="8.8.8.8";
            UDP_enb=0;UDP_idp4_idp6=0;UDP_server="192.168.1.22";UDP_port=3333;
            Zone_1="Zone 1";Zone_2="Zone 2";Zone_3="Zone 3";Zone_4="Zone 4";
            Scene_state=0;
        }

    }
}
