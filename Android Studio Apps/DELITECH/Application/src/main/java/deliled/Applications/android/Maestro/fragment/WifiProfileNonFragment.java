package deliled.Applications.android.Maestro.fragment;

import android.app.AlertDialog;
import android.bluetooth.BluetoothGattCharacteristic;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.text.InputFilter;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.SeekBar;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import androidx.fragment.app.Fragment;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import deliled.Applications.android.Maestro.DeviceScanActivity;
import deliled.Applications.android.Maestro.QR_CODE;
import deliled.Applications.android.Maestro.R;
import deliled.Applications.android.Maestro.serveur_access;

import static android.content.Context.MODE_PRIVATE;
import static deliled.Applications.android.Maestro.DeviceScanActivity.ACCESS;
import static deliled.Applications.android.Maestro.DeviceScanActivity.access_saved;
import static deliled.Applications.android.Maestro.DeviceScanActivity.access_super_admin;
import static deliled.Applications.android.Maestro.DeviceScanActivity.admin_compter;
import static deliled.Applications.android.Maestro.DeviceScanActivity.change_mode;
import static deliled.Applications.android.Maestro.DeviceScanActivity.mDevice;
import static deliled.Applications.android.Maestro.DeviceScanActivity.user_compter;
import static deliled.Applications.android.Maestro.MainActivity.CHAR_WRITE_LUMINOSITY;
import static deliled.Applications.android.Maestro.MainActivity.CHAR_WRITE_SYSTEM;
import static deliled.Applications.android.Maestro.MainActivity.Favoris;
import static deliled.Applications.android.Maestro.MainActivity.SERVICE_WRITE;
import static deliled.Applications.android.Maestro.MainActivity.SSID_modem;
import static deliled.Applications.android.Maestro.MainActivity.Udata_ota;
import static deliled.Applications.android.Maestro.MainActivity.Udata_time;
import static deliled.Applications.android.Maestro.MainActivity.Update_info;
import static deliled.Applications.android.Maestro.MainActivity.Zone_1;
import static deliled.Applications.android.Maestro.MainActivity.Zone_2;
import static deliled.Applications.android.Maestro.MainActivity.Zone_3;
import static deliled.Applications.android.Maestro.MainActivity.Zone_4;
import static deliled.Applications.android.Maestro.MainActivity.active;
import static deliled.Applications.android.Maestro.MainActivity.bleReadWrite;
import static deliled.Applications.android.Maestro.MainActivity.getDate;
import static deliled.Applications.android.Maestro.MainActivity.mBluetoothLeService;
import static deliled.Applications.android.Maestro.MainActivity.mConnected;
import static deliled.Applications.android.Maestro.MainActivity.mDeviceName;
import static deliled.Applications.android.Maestro.MainActivity.mGattCharacteristics;
import static deliled.Applications.android.Maestro.MainActivity.pause;
import static deliled.Applications.android.Maestro.MainActivity.restart_Activity;
import static deliled.Applications.android.Maestro.MainActivity.thread_pass;
import static deliled.Applications.android.Maestro.MainActivity.write_access;
import static deliled.Applications.android.Maestro.fragment.DeviceControFragment.Acceuil_isactive;
import static deliled.Applications.android.Maestro.fragment.ProfilsFragment.profile_list;
import static deliled.Applications.android.Maestro.fragment.ScenesFragment.scene_default;

public class WifiProfileNonFragment extends Fragment {
    private ArrayList<ArrayList<BluetoothGattCharacteristic>> mGattsCharacteristics = new ArrayList<>();
    public BluetoothGattCharacteristic mNotifyCharacteristic;
    private Button refresh, connect, ok, avancee, update, changer_acces;
    private EditText password, device_name;
    public Spinner s;
    private WifiManager wifiManager;
    private List<ScanResult> results;
    private ArrayAdapter<String> adapter;
    private View view1, view2;
    private TextView SSID_MODEM, access, text1, text2, text3, text4, text5;
    private Button pairbtn, unpairbtn, restart, config_default, renomer_zone, change_time;
    private ToggleButton pair_ZONE1, pair_ZONE2, pair_ZONE3, pair_ZONE4;
    public static TextView time_maestro;
    public static boolean write_time;

    View view;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.wifi_fragmnet, container, false);
        Acceuil_isactive = false;
        write_access = true;
        mGattsCharacteristics = mGattCharacteristics;
        avancee = view.findViewById(R.id.paramavance);
        avancee.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(requireActivity(), serveur_access.class);
                startActivity(intent);
            }
        });
        write_time = true;
        ok = view.findViewById(R.id.OK);
        connect = view.findViewById(R.id.Connect);
        change_time = view.findViewById(R.id.change_time_esp);
        update = view.findViewById(R.id.mise_a_jour);
        changer_acces = view.findViewById(R.id.pW_confirm);
        SSID_MODEM = view.findViewById(R.id.SSID);
        refresh = view.findViewById(R.id.refres);
        access = view.findViewById(R.id.pass);
        s = view.findViewById(R.id.spinner);
        password = view.findViewById(R.id.Password);
        config_default = view.findViewById(R.id.defaut);
        restart = view.findViewById(R.id.restart);
        avancee = view.findViewById(R.id.paramavance);
        text1 = view.findViewById(R.id.name_device);
        text2 = view.findViewById(R.id.wifi_connect);
        text3 = view.findViewById(R.id.textView4);
        text4 = view.findViewById(R.id.textView);
        text5 = view.findViewById(R.id.textView1);
        view1 = view.findViewById(R.id.view4);
        view2 = view.findViewById(R.id.view2);
        pair_ZONE1 = view.findViewById(R.id.ZONE_1);
        pair_ZONE2 = view.findViewById(R.id.ZONE_2);
        pair_ZONE3 = view.findViewById(R.id.ZONE_3);
        pair_ZONE4 = view.findViewById(R.id.ZONE_4);
        renomer_zone = view.findViewById(R.id.Rename_zone);
        time_maestro = view.findViewById(R.id.time_esp);
        device_name = view.findViewById(R.id.nameofdevice);
        device_name.setText(mDeviceName);
        pairbtn = view.findViewById(R.id.pairbt);
        unpairbtn = view.findViewById(R.id.unpair);
        View view_pairing = view.findViewById(R.id.pair_or_unpair);
        View view5 = view.findViewById(R.id.view5);
        rename();
        if (ACCESS) {
            access.setText("Accès : Administrateur");
            config_default.setVisibility(View.VISIBLE);
            restart.setVisibility(View.VISIBLE);
            avancee.setVisibility(View.VISIBLE);
            update.setVisibility(View.VISIBLE);
            refresh.setVisibility(View.VISIBLE);
            connect.setVisibility(View.VISIBLE);
            ok.setVisibility(View.VISIBLE);
            s.setVisibility(View.VISIBLE);
            password.setVisibility(View.VISIBLE);
            text1.setVisibility(View.VISIBLE);
            text2.setVisibility(View.VISIBLE);
            text3.setVisibility(View.VISIBLE);
            text4.setVisibility(View.VISIBLE);
            text5.setVisibility(View.VISIBLE);
            view1.setVisibility(View.VISIBLE);
            view2.setVisibility(View.VISIBLE);
            device_name.setVisibility(View.VISIBLE);
            SSID_MODEM.setVisibility(View.VISIBLE);
            view5.setVisibility(View.VISIBLE);
            time_maestro.setVisibility(View.VISIBLE);
            change_time.setVisibility(View.VISIBLE);
            view_pairing.setVisibility(View.VISIBLE);

        } else {
            access.setText("Accès : User");
            view_pairing.setVisibility(View.GONE);
            config_default.setVisibility(View.GONE);
            restart.setVisibility(View.GONE);
            avancee.setVisibility(View.GONE);
            update.setVisibility(View.GONE);
            refresh.setVisibility(View.GONE);
            connect.setVisibility(View.GONE);
            ok.setVisibility(View.GONE);
            s.setVisibility(View.GONE);
            password.setVisibility(View.GONE);
            text1.setVisibility(View.GONE);
            text2.setVisibility(View.GONE);
            text3.setVisibility(View.GONE);
            text4.setVisibility(View.GONE);
            text5.setVisibility(View.GONE);
            view1.setVisibility(View.GONE);
            view2.setVisibility(View.GONE);
            device_name.setVisibility(View.GONE);
            view5.setVisibility(View.GONE);
            time_maestro.setVisibility(View.GONE);
            change_time.setVisibility(View.GONE);
            SSID_MODEM.setVisibility(View.GONE);
        }
        config_default.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertconfigauto();
            }
        });
        restart.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String system1 = "{\"system\":1}";
                if (mConnected) {
                    Boolean checks = false;

                    do {
                        checks = writecharacteristic(3, 1, system1);

                    }
                    while (!checks);
                }
                Toast.makeText(requireContext(), " Redémarrage en cours, veuillez patienter. ", Toast.LENGTH_SHORT).show();
                Intent i = new Intent(requireContext(), DeviceScanActivity.class);
                i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(i);
            }
        });
        avancee.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(requireContext(), serveur_access.class);
                startActivity(intent);
            }
        });
        if (SSID_modem.equals("null")) {
            SSID_MODEM.setText("Vous n'êtes pas connecté");
            SSID_MODEM.setTextColor(Color.RED);
        } else {
            SSID_MODEM.setText("Vous êtes connecté à " + SSID_modem);
            SSID_MODEM.setTextColor(Color.GREEN);
        }
        refresh.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                requireActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        wifi();
                    }
                });
            }
        });
        wifi();
        ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = device_name.getText().toString();
                name = "{\"dname\":\"" + name + "\"}";
                if (mConnected) {
                    Boolean check = false;
                    do {
                        check = writecharacteristic(3, 0, name);
                    }
                    while (!check);
                }
                Toast.makeText(requireContext(), " Changement pris en compte au prochain redémarrage de l’application !  " +
                        "\n Le nom du module est : " + device_name.getText().toString(), Toast.LENGTH_LONG).show();
                final AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
                builder.setMessage("L’application va se fermer et la HuBBox va également redémarrer, êtes-vous sûr de vouloir continuer ?")
                        .setCancelable(false)
                        .setTitle("Modification du nom de la carte :")
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
                                Intent intent1 = new Intent(requireContext(), DeviceScanActivity.class);
                                intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                startActivity(intent1);
                            }
                        })
                        .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                dialog.cancel();
                            }
                        });
                final AlertDialog alert = builder.create();
                alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
                alert.show();

            }
        });
        connect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String pass = password.getText().toString();
                String access = String.valueOf(s.getSelectedItem());
                if (access.equals("null")) {
                    Toast.makeText(requireContext(), " Veuillez selectionner votre routeur ! ", Toast.LENGTH_SHORT).show();
                } else {
                    if (password.getText().toString().equals("")) {
                        Toast.makeText(requireContext(), " Veuillez renseigner le mot de passe du WiFi ", Toast.LENGTH_SHORT).show();
                    } else {
                        Toast.makeText(requireContext(), "Connexion à : " + "\nAccess : " + access, Toast.LENGTH_SHORT).show();
                        access = "{\"wa\":\"" + access + "\",\"wp\":\"" + pass + "\"}";
                        if (mConnected) {
                            Boolean checks;

                            do {
                                checks = writecharacteristic(3, 0, access);

                            }
                            while (!checks);

                            final AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
                            builder.setMessage("Afin de vous connecter à internet votre boiter va redémarrer")
                                    .setCancelable(false)
                                    .setTitle("Configuration d'acces :")
                                    .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                                        public void onClick(final DialogInterface dialog, final int id) {
                                            Intent i = new Intent(requireContext(), DeviceScanActivity.class);
                                            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                            String system1 = "{\"system\":1}";
                                            if (mConnected) {
                                                Boolean checks = false;

                                                do {
                                                    checks = writecharacteristic(3, 1, system1);

                                                }
                                                while (!checks);
                                            }
                                            startActivity(i);
                                        }
                                    })
                                    .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                                        public void onClick(final DialogInterface dialog, final int id) {
                                            dialog.cancel();
                                        }
                                    });
                            final AlertDialog alert = builder.create();
                            alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
                            alert.show();
                        }
                    }
                }
            }
        });
        update.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String system1 = "{\"update\":0}";
                if (mConnected) {
                    Boolean checks = false;

                    do {
                        checks = writecharacteristic(3, 1, system1);

                    }
                    while (!checks);
                    try {
                        Checking_UPDATE();
                    } catch (Throwable t) {
                        t.printStackTrace();
                    }

                }
            }
        });
        if (!access_super_admin) {
            changer_acces.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    String les_profiles = load("access.txt");
                    try {
                        JSONObject access = new JSONObject(les_profiles);
                        JSONArray les_access = access.getJSONArray("access");
                        String[] list_of_devices = new String[les_access.length()];
                        for (int i = 0; i < les_access.length(); i++) {
                            list_of_devices[i] = les_access.getString(i);
                            Log.d("My App", "array contains : " + list_of_devices[i]);
                        }
                        user_compter = 0;
                        admin_compter = 0;
                        if (list_of_devices.length == 1) {
                            final AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
                            builder.setMessage("Voulez vous sauvegarder le QR code apres le scan ?")
                                    .setCancelable(false)
                                    .setTitle("Configuration d'acces :")
                                    .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                                        public void onClick(final DialogInterface dialog, final int id) {
                                            access_saved = true;
                                            Intent intent1 = new Intent(requireContext(), QR_CODE.class);
                                            intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                            change_mode = false;
                                            thread_pass = true;
                                            startActivity(intent1);
                                        }
                                    })
                                    .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                                        public void onClick(final DialogInterface dialog, final int id) {
                                            access_saved = false;
                                            Intent intent1 = new Intent(requireContext(), QR_CODE.class);
                                            intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                            change_mode = false;
                                            thread_pass = true;
                                            startActivity(intent1);
                                            dialog.cancel();
                                        }
                                    });
                            final AlertDialog alert = builder.create();
                            alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
                            alert.show();
                        }
                        for (int i = 0; i < list_of_devices.length; i++) {
                            if (ACCESS) {
                                if (list_of_devices[i].contains(mDevice.getAddress()) & (list_of_devices[i].contains("MA")) & (list_of_devices[i].contains("USER"))) {
                                    access_saved = false;
                                    change_mode = true;
                                    ACCESS = false;
                                    restart_Activity = true;
                                    break;
                                }
                            }
                            if (!ACCESS) {
                                if (list_of_devices[i].contains(mDevice.getAddress()) & (list_of_devices[i].contains("MA")) & (list_of_devices[i].contains("ADMIN"))) {
                                    access_saved = false;
                                    change_mode = true;
                                    ACCESS = true;
                                    restart_Activity = true;
                                    break;
                                }
                            }
                            if (!(list_of_devices[i].contains("raki")) & (i == list_of_devices.length - 1)) {
                                final AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
                                builder.setMessage("Voulez-vous sauvegarder le QR-code après le scan ?")
                                        .setCancelable(true)
                                        .setTitle("Changer d’accès :")
                                        .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                                            public void onClick(final DialogInterface dialog, final int id) {
                                                access_saved = true;
                                                Intent intent1 = new Intent(requireContext(), QR_CODE.class);
                                                intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                                change_mode = false;
                                                thread_pass = true;
                                                startActivity(intent1);
                                            }
                                        })
                                        .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                                            public void onClick(final DialogInterface dialog, final int id) {
                                                access_saved = false;
                                                Intent intent1 = new Intent(requireContext(), QR_CODE.class);
                                                intent1.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                                change_mode = false;
                                                thread_pass = true;
                                                startActivity(intent1);
                                                dialog.cancel();
                                            }
                                        });
                                final AlertDialog alert = builder.create();
                                alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
                                alert.show();
                                break;
                            }
                        }
                    } catch (Throwable t) {
                        Log.e("My App", "Could not parse malformed JSON: " + les_profiles);
                    }
                }
            });
        }
        change_time.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Date tmp = new Date(Udata_time * 1000);
                Calendar cal = Calendar.getInstance();
                cal.setTime(tmp);
                int day = cal.get(Calendar.DATE);
                int mounth = cal.get(Calendar.MONTH);
                int year = cal.get(Calendar.YEAR);
                int hour = cal.get(Calendar.HOUR_OF_DAY);
                int minute = cal.get(Calendar.MINUTE);
                int secondes = cal.get(Calendar.SECOND);

                LinearLayout layout = new LinearLayout(requireContext());
                layout.setOrientation(LinearLayout.VERTICAL);
                final LinearLayout.LayoutParams lparam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                final TextView temp_text = new TextView(requireContext());
                temp_text.setLayoutParams(lparam);
                String temp = "Temp de la carte: ";
                temp_text.setText(temp);
                temp_text.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                temp_text.setGravity(Gravity.CENTER);
                layout.addView(temp_text);
                LinearLayout layout2 = new LinearLayout(requireContext());
                layout2.setOrientation(LinearLayout.HORIZONTAL);
                layout2.setGravity(Gravity.CENTER);
                final EditText temp_heure = new EditText(requireContext());
                temp_heure.setMaxLines(1);
                temp_heure.setFilters(new InputFilter[]{new InputFilter.LengthFilter(2)});
                temp_heure.setText(Integer.toString(hour));
                temp_heure.setInputType(EditorInfo.TYPE_CLASS_NUMBER);
                layout2.addView(temp_heure);
                final TextView heure_min = new TextView(requireContext());
                String dot = " : ";
                heure_min.setText(dot);
                layout2.addView(heure_min);
                final EditText temp_minute = new EditText(requireContext());
                temp_minute.setMaxLines(1);
                temp_minute.setFilters(new InputFilter[]{new InputFilter.LengthFilter(2)});
                temp_minute.setText(Integer.toString(minute));
                temp_minute.setInputType(EditorInfo.TYPE_CLASS_NUMBER);
                layout2.addView(temp_minute);
                final TextView min_sec = new TextView(requireContext());
                min_sec.setText(dot);
                layout2.addView(min_sec);
                final EditText temp_seconds = new EditText(requireContext());
                temp_seconds.setMaxLines(1);
                temp_seconds.setFilters(new InputFilter[]{new InputFilter.LengthFilter(2)});
                temp_seconds.setText(Integer.toString(secondes));
                temp_seconds.setInputType(EditorInfo.TYPE_CLASS_NUMBER);
                layout2.addView(temp_seconds);
                final TextView date_text = new TextView(requireContext());
                date_text.setLayoutParams(lparam);
                String date = "Date de la carte: ";
                date_text.setText(date);
                date_text.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                date_text.setGravity(Gravity.CENTER);
                layout.addView(layout2);
                layout.addView(date_text);
                LinearLayout layout3 = new LinearLayout(requireContext());
                layout3.setOrientation(LinearLayout.HORIZONTAL);
                layout3.setGravity(Gravity.CENTER);
                final EditText day_carte = new EditText(requireContext());
                day_carte.setMaxLines(1);
                day_carte.setFilters(new InputFilter[]{new InputFilter.LengthFilter(2)});
                day_carte.setText(Integer.toString(day));
                day_carte.setInputType(EditorInfo.TYPE_CLASS_NUMBER);
                layout3.addView(day_carte);
                final TextView day_month = new TextView(requireContext());
                String slash = " / ";
                day_month.setText(slash);
                layout3.addView(day_month);
                final EditText mounth_carte = new EditText(requireContext());
                mounth_carte.setMaxLines(1);
                mounth_carte.setFilters(new InputFilter[]{new InputFilter.LengthFilter(2)});
                mounth_carte.setText(Integer.toString(mounth + 1));
                mounth_carte.setInputType(EditorInfo.TYPE_CLASS_NUMBER);
                layout3.addView(mounth_carte);
                final TextView month_year = new TextView(requireContext());
                month_year.setText(slash);
                layout3.addView(month_year);
                final EditText year_carte = new EditText(requireContext());
                year_carte.setMaxLines(1);
                year_carte.setFilters(new InputFilter[]{new InputFilter.LengthFilter(4)});
                year_carte.setText(Integer.toString(year));
                year_carte.setInputType(EditorInfo.TYPE_CLASS_NUMBER);
                layout3.addView(year_carte);
                layout.addView(layout3);

                final AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
                builder.setCancelable(true)
                        .setTitle("Configuration du temps")
                        .setView(layout)
                        .setPositiveButton("Confirmer", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                Long timestamp;
                                if (Integer.parseInt(day_carte.getText().toString()) > 31)
                                    day_carte.setText("31");
                                if (Integer.parseInt(mounth_carte.getText().toString()) > 12)
                                    mounth_carte.setText("12");
                                if (Integer.parseInt(temp_heure.getText().toString()) > 23)
                                    temp_heure.setText("23");
                                if (Integer.parseInt(temp_minute.getText().toString()) > 59)
                                    temp_minute.setText("59");
                                if (Integer.parseInt(temp_seconds.getText().toString()) > 59)
                                    temp_seconds.setText("59");

                                try {
                                    String inputDateInString = day_carte.getText().toString() + "/" + mounth_carte.getText().toString() + "/" + year_carte.getText().toString() +
                                            " " + temp_heure.getText().toString() + ":" + temp_minute.getText().toString() + ":" + temp_seconds.getText().toString();
                                    Log.i("timestamp :", inputDateInString);
                                    DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
                                    Timestamp ts = new Timestamp((df.parse(inputDateInString)).getTime());
                                    timestamp = ts.getTime() / 1000;
                                } catch (ParseException e) {
                                    e.printStackTrace();
                                    timestamp = null;
                                }
                                int mtimezone = TimeZone.getDefault().getRawOffset() / 1000;
                                String trame_time = "{\"Time_config\":[" + timestamp + "," + mtimezone + "]}";
                                if (mConnected) {
                                    Boolean check = false;

                                    do {
                                        check = writecharacteristic(SERVICE_WRITE, CHAR_WRITE_SYSTEM, trame_time);
                                        if (!mConnected) {
                                            break;
                                        }
                                    }
                                    while (!check);
                                }
                            }
                        })
                        .setNegativeButton("Retour", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                dialog.cancel();
                            }
                        });
                final AlertDialog alert = builder.create();
                alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
                alert.show();
            }
        });
        RENAME_ZONE();
        return view;
    }

    public static void time_esp() {
        try {
            time_maestro.setText("Le temps de la carte est :\n\n" + getDate(Udata_time * 1000) + "\n");
        } catch (NullPointerException e) {
            e.printStackTrace();
        }
    }

    public String load(String FILE_NAME) {
        FileInputStream fis = null;

        try {
            fis = requireActivity().openFileInput(FILE_NAME);
            InputStreamReader isr = new InputStreamReader(fis);
            BufferedReader br = new BufferedReader(isr);
            StringBuilder sb = new StringBuilder();
            String text;

            while ((text = br.readLine()) != null) {
                sb.append(text).append("\n");
            }
            return sb.toString();

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (fis != null) {
                try {
                    fis.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }

    public void Checking_UPDATE() {
        LinearLayout layout = new LinearLayout(requireContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setGravity(Gravity.CENTER);
        final ProgressBar progress = new ProgressBar(requireContext());
        layout.addView(progress);
        final AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
        builder.setCancelable(true)
                .setTitle("Recherche de mises à jour")
                .setMessage("Veuillez patienter lors de la recherche de mises à jour pour votre HuBBox")
                .setView(layout);
        final AlertDialog alert = builder.create();
        alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
        alert.show();
        new CountDownTimer(3000, 3000) {
            @Override
            public void onTick(long millisUntilFinished) {
                if (Update_info == 1) {
                    alert.cancel();
                    Toast.makeText(requireContext(), " Votre HuBBbox est à jour !", Toast.LENGTH_LONG).show();
                    cancel();
                }
                if (Update_info == 2) {
                    cancel();
                    alert.cancel();
                    UPDATING();
                }
                if (SSID_modem.equals("null")) {
                    alert.cancel();
                    Toast.makeText(requireContext(), " Votre HuBBbox est n'est pas en ligne , Voulez vous connecter votre HuBBox avec votre modem !", Toast.LENGTH_LONG).show();
                    cancel();
                }
            }

            @Override
            public void onFinish() {
                start();
            }
        }.start();
    }

    public void UPDATING() {
        LinearLayout layout = new LinearLayout(requireContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setGravity(Gravity.CENTER);
        final SeekBar progress = new SeekBar(requireContext());
        progress.setClickable(false);
        layout.addView(progress);
        final LinearLayout.LayoutParams lparam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        final TextView progress_ota = new TextView(requireContext());
        progress_ota.setLayoutParams(lparam);
        progress_ota.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
        layout.addView(progress_ota);
        final AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
        builder.setCancelable(false)
                .setTitle("Mise à jour HuBBox")
                .setMessage("Veuillez patienter, nous téléchargeons la dernière version du firmware sur votre HuBBox ... ")
                .setView(layout);
        final AlertDialog update = builder.create();
        update.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
        update.show();
        new CountDownTimer(1000, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                update.setMessage("Veuillez patienter, nous téléchargeons la dernière version du firmware sur votre HuBBox ...");
                progress.setProgress(Udata_ota);
                progress_ota.setText(Udata_ota + "%");
                if (Update_info == 0) {
                    active = false;
                    Handler handler = new Handler();
                    handler.postDelayed(new Runnable() {
                        public void run() {
                            update.cancel();
                            Toast.makeText(requireContext(), " Votre HuBBbox va redémarrer", Toast.LENGTH_LONG).show();
                            mBluetoothLeService.disconnect();
                            cancel();
                            Handler handler = new Handler();
                            handler.postDelayed(new Runnable() {
                                public void run() {
                                    Intent i = new Intent(requireContext(), DeviceScanActivity.class);
                                    i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                    startActivity(i);
                                }
                            }, 500);
                        }
                    }, 1000);
                }
                if (Update_info == 1) {
                    Handler handler = new Handler();
                    handler.postDelayed(new Runnable() {
                        public void run() {
                            update.cancel();
                            Toast.makeText(requireContext(), " Un erreur s'est produit dans le telechargement du firmware , veuillez ressayer ! !", Toast.LENGTH_LONG).show();
                            mBluetoothLeService.disconnect();
                            cancel();
                        }
                    }, 1000);
                }
            }

            @Override
            public void onFinish() {
                start();
            }
        }.start();
    }

    private void alertconfigauto() {
        final AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
        builder.setMessage("Souhaitez-vous réinitialiser toutes les données de configuration enregistrées sur votre application ?")
                .setCancelable(false)
                .setTitle("Attention")
                .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, final int id) {
                        String system = "{\"system\":0}";
                        if (mConnected) {
                            Boolean check = false;

                            do {
                                check = writecharacteristic(3, 1, system);

                            }
                            while (!check);
                        }
                        save("access.txt", "{\"access\":[\"raki\"]}");
                        save("Scenes.txt", scene_default);
                        save("profile.txt", profile_list);
                        save("Favoris.txt", Favoris);
                        pause(220);
                        String x = TimeZone.getDefault().getDisplayName(false, TimeZone.SHORT, Locale.getDefault());
                        // Current timezone and date
                        TimeZone timeZone = TimeZone.getDefault();
                        //boolean usedaylight=false;
                        boolean observedaylight = false;
                        Date nowDate = new Date();
                        // Daylight Saving time
                        if (timeZone.useDaylightTime()) {
                            // DST is used
                            // save that now we are in DST mode
                            if (timeZone.inDaylightTime(nowDate)) {
                                // Now you are in use of DST mode
                                observedaylight = true;
                            } else {
                                // DST mode is not used for this timezone
                                observedaylight = false;
                            }
                        }
                        int summer_time = observedaylight ? 1 : 0;
                        //Toast.makeText(getBaseContext(), "observedaylight = "+observedaylight+", usedaylight = "+usedaylight, Toast.LENGTH_LONG).show();
                        String zone_and_summer = "{\"tz\":\"" + x + "\",\"summer\":" + summer_time + "}";
                        if (mConnected) {
                            writecharacteristic(3, 0, zone_and_summer);
                        }
                        Toast.makeText(requireContext(), " Configuration par défaut réalisée! ", Toast.LENGTH_SHORT).show();
                    }
                })
                .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, final int id) {
                        dialog.cancel();
                    }
                });
        final AlertDialog alert = builder.create();
        alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_slide;
        alert.show();
    }

    int pairing_value = 0;

    public void RENAME_ZONE() {
        pair_ZONE1.setText(Zone_1);
        pair_ZONE2.setText(Zone_2);
        pair_ZONE3.setText(Zone_3);
        pair_ZONE4.setText(Zone_4);
        pair_ZONE1.setTextColor(getResources().getColor(R.color.White));
        pair_ZONE2.setTextColor(getResources().getColor(R.color.White));
        pair_ZONE3.setTextColor(getResources().getColor(R.color.White));
        pair_ZONE4.setTextColor(getResources().getColor(R.color.White));
        pair_ZONE1.setText(Zone_1);
        pair_ZONE1.setTextOff(Zone_1);
        pair_ZONE1.setTextOn(Zone_1);
        pair_ZONE2.setText(Zone_2);
        pair_ZONE2.setTextOff(Zone_2);
        pair_ZONE2.setTextOn(Zone_2);
        pair_ZONE3.setText(Zone_3);
        pair_ZONE3.setTextOff(Zone_3);
        pair_ZONE3.setTextOn(Zone_3);
        pair_ZONE4.setText(Zone_4);
        pair_ZONE4.setTextOff(Zone_4);
        pair_ZONE4.setTextOn(Zone_4);
        pair_ZONE1.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    pair_ZONE2.setChecked(false);
                    pair_ZONE3.setChecked(false);
                    pair_ZONE4.setChecked(false);
                    pairing_value = 1;
                }
            }
        });
        pair_ZONE2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    pair_ZONE1.setChecked(false);
                    pair_ZONE3.setChecked(false);
                    pair_ZONE4.setChecked(false);
                    pairing_value = 2;
                }
            }
        });
        pair_ZONE3.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    pair_ZONE1.setChecked(false);
                    pair_ZONE2.setChecked(false);
                    pair_ZONE4.setChecked(false);
                    pairing_value = 4;
                }
            }
        });
        pair_ZONE4.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    pair_ZONE1.setChecked(false);
                    pair_ZONE3.setChecked(false);
                    pair_ZONE2.setChecked(false);
                    pairing_value = 8;
                }
            }
        });
        pairbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (pairing_value == 0) {
                    pairbtn.setTextColor(getResources().getColor(R.color.Red));
                    Toast.makeText(requireContext(), "Aucune Zone est selectionée !", Toast.LENGTH_LONG).show();
                    Handler handler = new Handler();
                    handler.postDelayed(new Runnable() {
                        public void run() {
                            pairbtn.setTextColor(getResources().getColor(R.color.White));
                        }
                    }, 200);
                } else {
                    pairbtn.setTextColor(getResources().getColor(R.color.Green));
                    String Vplus = "{\"light\":[5,1," + pairing_value + "]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, Vplus);
                    Handler handler = new Handler();
                    handler.postDelayed(new Runnable() {
                        public void run() {
                            pairbtn.setTextColor(getResources().getColor(R.color.White));
                        }
                    }, 200);
                }
            }
        });

        unpairbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String Vplus = "{\"light\":[5,0," + pairing_value + "]}";
                writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, Vplus);
            }
        });
        renomer_zone.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                LinearLayout layout = new LinearLayout(requireContext());
                layout.setOrientation(LinearLayout.VERTICAL);
                LinearLayout layout2 = new LinearLayout(requireContext());
                layout2.setOrientation(LinearLayout.HORIZONTAL);
                final TextView prof_col = new TextView(requireContext());
                String col = "ZONE 1 : ";
                prof_col.setText(col);
                final LinearLayout.LayoutParams lparam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                prof_col.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                layout2.addView(prof_col);

                final EditText Zone1 = new EditText(requireContext());
                Zone1.setHint("Nom de la Zone 1");
                Zone1.setMaxLines(1);
                Zone1.setText(Zone_1);
                Zone1.setFilters(new InputFilter[]{new InputFilter.LengthFilter(7)});
                Zone1.setLayoutParams(lparam);
                Zone1.setInputType(EditorInfo.TYPE_CLASS_TEXT);
                layout2.addView(Zone1);
                layout.addView(layout2);

                LinearLayout layout3 = new LinearLayout(requireContext());
                layout3.setOrientation(LinearLayout.HORIZONTAL);
                final TextView prof_col2 = new TextView(requireContext());
                String col2 = "ZONE 2 : ";
                prof_col2.setText(col2);
                prof_col2.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                layout3.addView(prof_col2);

                final EditText Zone2 = new EditText(requireContext());
                Zone2.setHint("Nom de la Zone 2");
                Zone2.setMaxLines(1);
                Zone2.setText(Zone_2);
                Zone2.setInputType(EditorInfo.TYPE_CLASS_TEXT);
                Zone2.setFilters(new InputFilter[]{new InputFilter.LengthFilter(7)});
                Zone2.setLayoutParams(lparam);
                layout3.addView(Zone2);
                layout.addView(layout3);

                LinearLayout layout4 = new LinearLayout(requireContext());
                layout4.setOrientation(LinearLayout.HORIZONTAL);
                final TextView prof_col3 = new TextView(requireContext());
                String col3 = "ZONE 3 : ";
                prof_col3.setText(col3);
                prof_col3.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                layout4.addView(prof_col3);

                final EditText Zone3 = new EditText(requireContext());
                Zone3.setHint("Nom de la Zone 3");
                Zone3.setMaxLines(1);
                Zone3.setText(Zone_3);
                Zone3.setInputType(EditorInfo.TYPE_CLASS_TEXT);
                Zone3.setFilters(new InputFilter[]{new InputFilter.LengthFilter(7)});
                Zone3.setLayoutParams(lparam);
                layout4.addView(Zone3);
                layout.addView(layout4);

                LinearLayout layout5 = new LinearLayout(requireContext());
                layout5.setOrientation(LinearLayout.HORIZONTAL);
                final TextView prof_col4 = new TextView(requireContext());
                String col4 = "ZONE 4 : ";
                prof_col4.setText(col4);
                prof_col4.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                layout5.addView(prof_col4);

                final EditText Zone4 = new EditText(requireContext());
                Zone4.setHint("Nom de la Zone 4");
                Zone4.setMaxLines(1);
                Zone4.setText(Zone_4);
                Zone4.setInputType(EditorInfo.TYPE_CLASS_TEXT);
                Zone4.setFilters(new InputFilter[]{new InputFilter.LengthFilter(7)});
                Zone4.setLayoutParams(lparam);
                layout5.addView(Zone4);
                layout.addView(layout5);

                final AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
                builder.setMessage("Changer les noms des Zones : (7 caractères max) ")
                        .setTitle("Réglages")
                        .setCancelable(false)
                        .setView(layout)
                        .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                Zone_1 = Zone1.getText().toString();
                                Zone_2 = Zone2.getText().toString();
                                Zone_3 = Zone3.getText().toString();
                                Zone_4 = Zone4.getText().toString();
                                pair_ZONE1.setText(Zone1.getText());
                                pair_ZONE2.setText(Zone2.getText());
                                pair_ZONE3.setText(Zone3.getText());
                                pair_ZONE4.setText(Zone4.getText());
                                pair_ZONE1.setTextOn(Zone1.getText());
                                pair_ZONE2.setTextOn(Zone2.getText());
                                pair_ZONE3.setTextOn(Zone3.getText());
                                pair_ZONE4.setTextOn(Zone4.getText());
                                pair_ZONE1.setTextOff(Zone1.getText());
                                pair_ZONE2.setTextOff(Zone2.getText());
                                pair_ZONE3.setTextOff(Zone3.getText());
                                pair_ZONE4.setTextOff(Zone4.getText());
                                //Log.d("zones", "zone 1 : " + Zone_1 +"zone 2 : " + Zone_2 +"zone 3 : " + Zone_3 +"zone 4 : " + Zone_4 );
                                String zonage = "{\"zones\":[" + Zone_1 + "," + Zone_2 + "," + Zone_3 + "," + Zone_4 + "]}";
                                writecharacteristic(SERVICE_WRITE, CHAR_WRITE_SYSTEM, zonage);
                            }
                        })
                        .setNegativeButton("Non", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                dialog.cancel();
                            }
                        });
                final AlertDialog alert = builder.create();
                alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
                alert.show();
            }
        });
    }

    public void rename() {
        pair_ZONE1.setText(Zone_1);
        pair_ZONE2.setText(Zone_2);
        pair_ZONE3.setText(Zone_3);
        pair_ZONE4.setText(Zone_4);
        pair_ZONE1.setTextOn(Zone_1);
        pair_ZONE2.setTextOn(Zone_2);
        pair_ZONE3.setTextOn(Zone_3);
        pair_ZONE4.setTextOn(Zone_4);
        pair_ZONE1.setTextOff(Zone_1);
        pair_ZONE2.setTextOff(Zone_2);
        pair_ZONE3.setTextOff(Zone_3);
        pair_ZONE4.setTextOff(Zone_4);
    }

    public void save(String FILE_NAME, String text) {
        FileOutputStream fos = null;
        try {
            fos = requireActivity().openFileOutput(FILE_NAME, MODE_PRIVATE);
            fos.write(text.getBytes());
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (fos != null) {
                try {
                    fos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }


    public boolean writecharacteristic(int i, int j, String data) {
        boolean write = false;
        bleReadWrite = true;
        try {
            final BluetoothGattCharacteristic charac = mGattsCharacteristics.get(i).get(j);
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

    BroadcastReceiver wifiReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            results = wifiManager.getScanResults();
            requireActivity().unregisterReceiver(this);
            String[] arraySpinner = new String[results.size()];
            int h = 0;
            for (ScanResult scanResult : results) {
                arraySpinner[h] = scanResult.SSID;
                Log.i("WIFI", scanResult.toString());
                h = h + 1;
            }
            adapter = new ArrayAdapter<>(requireContext(), R.layout.spinner_item, arraySpinner);
            adapter.setDropDownViewResource(R.layout.drop_list_spinner);
            s.setAdapter(adapter);
        }
    };

    public void wifi() {
        wifiManager = (WifiManager) requireActivity().getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        if (!wifiManager.isWifiEnabled()) {
            Toast.makeText(requireContext(), "Activation Wifi en cours ...", Toast.LENGTH_LONG).show();
            wifiManager.setWifiEnabled(true);
        }
        requireActivity().registerReceiver(wifiReceiver, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
        wifiManager.startScan();
        Toast.makeText(requireContext(), "Scan WiFi ...", Toast.LENGTH_SHORT).show();
    }
}
