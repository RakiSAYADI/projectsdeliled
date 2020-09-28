package deliled.Applications.android.Maestro.fragment;

import android.app.AlertDialog;
import android.bluetooth.BluetoothGattCharacteristic;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import androidx.fragment.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

import deliled.Applications.android.Maestro.R;
import deliled.Applications.android.Maestro.ajustement_luminosite;
import deliled.Applications.android.Maestro.co2;
import deliled.Applications.android.Maestro.cycle_circa;
import deliled.Applications.android.Maestro.veille_detections;

import static deliled.Applications.android.Maestro.MainActivity.*;
import static deliled.Applications.android.Maestro.fragment.DeviceControFragment.Acceuil_isactive;

public class ProfilsFragment extends Fragment {
    Button config_adjus,config_adjus_manu,config_veille,config_cycle_circa,restart,CO2_config;
    ImageButton rename_profile;
    Switch switch_ajustement,switch_ajustement_man,switch_veille,switch_circa,switch_co2;
    Spinner profiles;
    public BluetoothGattCharacteristic mNotifyCharacteristic;
    public ArrayList<ArrayList<BluetoothGattCharacteristic>> mGattprCharacteristics = new ArrayList<>();
    public boolean let_config,let_lum;
    public static boolean what_lum;

    View view;
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.profil_fragment, container, false);
        Acceuil_isactive=false;
        mGattprCharacteristics= mGattCharacteristics;
        let_config=false;
        config_adjus=view.findViewById(R.id.switch_expert);
        config_adjus_manu=view.findViewById(R.id.switch_expert_manu);
        switch_ajustement_man=view.findViewById(R.id.switch_ajust_manu);
        config_veille=view.findViewById(R.id.veille_expert);
        config_cycle_circa=view.findViewById(R.id.cyc_expert);
        switch_ajustement=view.findViewById(R.id.switch_ajust);
        switch_veille=view.findViewById(R.id.switchveille);
        switch_circa=view.findViewById(R.id.switchcyc);
        rename_profile=view.findViewById(R.id.imagemodif);
        profiles=view.findViewById(R.id.spinnerprofile);
        restart=view.findViewById(R.id.restart_values);
        switch_co2=view.findViewById(R.id.switchco2);
        CO2_config=view.findViewById(R.id.co2_experting);
        switch_veille.setText(R.string.descative);
        switch_circa.setText(R.string.descative);
        switch_ajustement.setText(R.string.descative);
        switch_ajustement_man.setText(R.string.descative);
        switch_co2.setText(R.string.descative);
        switch_veille.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (switch_veille.isChecked()){
                    switch_veille.setText(R.string.active);
                    veille_enb=1;
                }else {
                    veille_enb=0;
                    switch_veille.setText(R.string.descative);
                }

                if (mConnected&let_config) {
                    Boolean check = false;

                    do {
                        String enc_dec ="{\"pdata\":["+enc_enb+",\""+enc_days+"\",\""+enc_zones+"\","+ heure_enc_time_h+""+format(heure_enc_time_m)+ ","+enc_2_enb+",\""+enc_2_days+"\",\""+enc_2_zones+"\","+ heure_enc_2_time_h+""+format(heure_enc_2_time_m)+
                                ","+dec_enb+",\""+days+"\",\""+Zone_veille+"\","+ heure_denc_h+""+format(heure_denc_m)+","+dec_2_enb+",\""+days_2+"\",\""+Zone_2_veille+"\","+ heure_denc_2_h+""+format(heure_denc_2_m)+"]," +
                                "\"veille\":["+ veille_enb+","+pir_enc+ ","+ detec_denc_m+",\""+pir_days+"\",\""+pir_zones+"\"]}";
                        check = writecharacteristic(3, 0, enc_dec );
                        if (check) {
                            Toast.makeText(getContext(), "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                        }
                        if (!mConnected)
                        {
                            break;
                        }
                    }
                    while (!check);
                }
            }
        });
        switch_ajustement.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                //switchColor(isChecked);
                if(switch_ajustement.isChecked())
                {
                    switch_ajustement.setText(R.string.active);
                }else
                {
                    switch_ajustement.setText(R.string.descative);
                }
                if ((!switch_ajustement.isChecked())&&(!switch_ajustement_man.isChecked())){
                    lum_active=0;
                }
                else {
                    lum_active=1;
                }
                if (switch_ajustement.isChecked()){
                    let_lum=false;
                    switch_ajustement_man.setChecked(false);
                    let_lum=false;
                    auto_or_fixe=1;
                }
                if (mConnected&let_config&(!let_lum)) {
                    Boolean check = false;
                    Log.i("profils","writng lum auto");
                    do {
                        String lum ="{\"lum\":["+ lum_active+ ","+ auto_val+",\""+ Zone_lum+"\","+ lum_zone_1+ ","+ lum_zone_2+","+ lum_zone_3+","+ lum_zone_4+","+ lum_zone_010v+ ","+ lum_tewenty_percent+","+
                                auto_or_fixe+",\""+zones_lum_fixe+
                                "\","+lum_start_fixe_zone_1_1+","+lum_start_fixe_zone_2_1+","+lum_start_fixe_zone_3_1+","+lum_start_fixe_zone_4_1+","+lum_fixe_start_zone_volt_1+
                                ","+lum_fixe_start_h_1+""+format(lum_fixe_start_m_1)+
                                ","+lum_fixe_start_h_2+""+format(lum_fixe_start_m_2)+","+lum_start_fixe_zone_1_2+","+lum_start_fixe_zone_2_2+","+lum_start_fixe_zone_3_2+","+lum_start_fixe_zone_4_2+","+lum_fixe_start_zone_volt_2+
                                ","+lum_fixe_end_h_1+""+format(lum_fixe_end_m_1)+","+lum_end_fixe_zone_1_1+","+lum_end_fixe_zone_2_1+","+lum_end_fixe_zone_3_1+","+lum_end_fixe_zone_4_1+","+lum_end_fixe_zone_volt_1+
                                ","+lum_fixe_end_h_2+""+format(lum_fixe_end_m_2)+","+lum_end_fixe_zone_1_2+","+lum_end_fixe_zone_2_2+","+lum_end_fixe_zone_3_2+","+lum_end_fixe_zone_4_2+","+lum_end_fixe_zone_volt_2+"]}";

                        check = writecharacteristic(3, 0, lum );
                        if (check) {
                            Toast.makeText(getContext(), "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                        }
                        if (!mConnected)
                        {
                            break;
                        }
                    }
                    while (!check);
                }
            }
        });
        switch_ajustement_man.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {

                if(switch_ajustement_man.isChecked())
                {
                    switch_ajustement_man.setText(R.string.active);
                }else
                {
                    switch_ajustement_man.setText(R.string.descative);
                }
                if (switch_ajustement_man.isChecked()){
                    let_lum=true;
                    switch_ajustement.setChecked(false);
                    let_lum=true;
                    auto_or_fixe=0;
                }
                if ((!switch_ajustement.isChecked())&&(!switch_ajustement_man.isChecked())){
                    lum_active=0;
                }
                else
                {
                    lum_active=1;
                }
                if (mConnected&let_config&let_lum) {
                    Boolean check = false;
                    Log.i("profils","writng lum man");
                    do {
                        String lum ="{\"lum\":["+ lum_active+ ","+ auto_val+",\""+ Zone_lum+"\","+ lum_zone_1+ ","+ lum_zone_2+","+ lum_zone_3+","+ lum_zone_4+","+ lum_zone_010v+ ","+ lum_tewenty_percent+","+
                                auto_or_fixe+",\""+zones_lum_fixe+"\","+lum_start_fixe_zone_1_1+","+lum_start_fixe_zone_2_1+","+lum_start_fixe_zone_3_1+","+lum_start_fixe_zone_4_1+","+lum_fixe_start_zone_volt_1+
                                ","+lum_fixe_start_h_1+""+format(lum_fixe_start_m_1)+
                                ","+lum_fixe_start_h_2+""+format(lum_fixe_start_m_2)+","+lum_start_fixe_zone_1_2+","+lum_start_fixe_zone_2_2+","+lum_start_fixe_zone_3_2+","+lum_start_fixe_zone_4_2+","+lum_fixe_start_zone_volt_2+
                                ","+lum_fixe_end_h_1+""+format(lum_fixe_end_m_1)+","+lum_end_fixe_zone_1_1+","+lum_end_fixe_zone_2_1+","+lum_end_fixe_zone_3_1+","+lum_end_fixe_zone_4_1+","+lum_end_fixe_zone_volt_1+
                                ","+lum_fixe_end_h_2+""+format(lum_fixe_end_m_2)+","+lum_end_fixe_zone_1_2+","+lum_end_fixe_zone_2_2+","+lum_end_fixe_zone_3_2+","+lum_end_fixe_zone_4_2+","+lum_end_fixe_zone_volt_2+"]}";

                        check = writecharacteristic(3, 0, lum );
                        if (check) {
                            Toast.makeText(getContext(), "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                        }
                        if (!mConnected)
                        {
                            break;
                        }
                    }
                    while (!check);
                }
            }
        });
        switch_circa.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (switch_circa.isChecked()){
                    cyc_enb=1;
                    switch_circa.setText(R.string.active);
                }else {
                    cyc_enb=0;
                    switch_circa.setText(R.string.descative);
                }
                if (mConnected&let_config) {
                    Boolean check = false;
                    do {
                        String cyc ="{\"cycle\":["+ cyc_enb+ ",\""+ Zone_CC+ "\",\""+ Enb_CC+ "\","+Cc_bet_times+","+ heure_p1_h+ ""+format(heure_p1_m)+","+ p1_temp+","+ heure_p2_h+""+format(heure_p2_m)+ ","+ p2_temp+","+ heure_p3_h+ ""+format(heure_p3_m)+","+ p3_temp+","+ heure_p4_h+ ""+format(heure_p4_m)+","+ p4_temp+"]}";
                        check = writecharacteristic(3, 0, cyc );
                        if (check) {
                            Toast.makeText(getContext(), "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                        }
                        if (!mConnected)
                        {
                            break;
                        }
                    }
                    while (!check);
                }
            }
        });
        switch_co2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (switch_co2.isChecked()){
                    co2_enb=1;
                    switch_co2.setText(R.string.active);
                }else {
                    co2_enb=0;
                    switch_co2.setText(R.string.descative);
                }
                if (mConnected&let_config) {
                    Boolean check = false;

                    do {
                        String co2_s ="{\"co2\":["+ co2_enb+","+ co2_email_enb+",\""+ co2_email+"\","+ co2_notify+","+ co2_zone_enb+",\""+ co2_zone+"\","+ co2_val+"]}";
                        check = writecharacteristic(3, 0, co2_s );
                        if (check) {
                            Toast.makeText(getContext(), "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                        }
                        if (!mConnected)
                        {
                            break;
                        }
                    }
                    while (!check);
                }
            }
        });
        CO2_config.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final Intent intent = new Intent(getContext(), co2.class);
                startActivity(intent);
            }
        });
        restart.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
                builder.setMessage("Souhaitez-vous réinitialiser toutes les profils enregistrées sur votre application ?")
                        .setCancelable(false)
                        .setTitle("Attention")
                        .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                //save("profile.txt",profile_list);
                                Displaydata(profile_list);
                                String system2 = "{\"profile_init\":0}";
                                if (mConnected) {
                                    Boolean check = false;
                                    do {
                                        check = writecharacteristic(3, 1, system2);
                                        if (check) {
                                            Toast.makeText(getContext(), "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                                        }
                                        if (!mConnected)
                                        {
                                            break;
                                        }
                                    }
                                    while (!check);
                                }
                                //read_text_json();
                                read_profile();
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
        config_adjus.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final Intent intent = new Intent(getContext(), ajustement_luminosite.class);
                what_lum=true;
                startActivity(intent);
            }
        });
        config_adjus_manu.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final Intent intent = new Intent(getContext(), ajustement_luminosite.class);
                what_lum=false;
                startActivity(intent);
            }
        });
        config_veille.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final Intent intent = new Intent(getContext(), veille_detections.class);
                startActivity(intent);
            }
        });
        config_cycle_circa.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final Intent intent = new Intent(getContext(), cycle_circa.class);
                startActivity(intent);
            }
        });
        read_profile();
        return view;
        
    }
    public String format (int x)
    {
        return String.format("%02d",x);
    }
    public void write_profile()
    {
        if((!switch_ajustement.isChecked())&&(!switch_ajustement_man.isChecked())){lum_active=0;}
        else
        {
            if(!switch_ajustement_man.isChecked())
            {
                lum_active=1;auto_or_fixe=1;
            }
            else
            {
                lum_active=1;auto_or_fixe=0;
            }
        }
        if(switch_veille.isChecked()){
            veille_enb=1;}else {
            veille_enb=0;}
        if(switch_circa.isChecked()){
            cyc_enb=1;}else {
            cyc_enb=0;}
        if(switch_co2.isChecked()){
            co2_enb=1;}else {
            co2_enb=0;}
        try {
            if (Zone_CC.equals("null")) {
                Zone_CC = "0";
            }
            if (Zone_veille.equals("null")) {
                Zone_veille = "0";
            }
        }
        catch (NullPointerException e)
        {
            Zone_CC = "0";
            Zone_veille = "0";
        }
        //save_format_json();
        if (state==1)
        {
            lum_zone_1=Udata_lum_zone_1;
            lum_zone_2=Udata_lum_zone_2;
            lum_zone_3=Udata_lum_zone_3;
            lum_zone_4=Udata_lum_zone_4;
            lum_zone_010v=Udata_lum_zone_010v;
        }
        String totale=
                "{\"profilenumber\":\""+ profile_number+"\",\"pname\":\""+ "my_profile"+ "\"," +
                        "\"pdata\":["+enc_enb+",\""+enc_days+"\",\""+enc_zones+"\","+ heure_enc_time_h+""+format(heure_enc_time_m)+ ","+enc_2_enb+",\""+enc_2_days+"\",\""+enc_2_zones+"\","+ heure_enc_2_time_h+""+format(heure_enc_2_time_m)+
                        ","+dec_enb+",\""+days+"\",\""+Zone_veille+"\","+ heure_denc_h+""+format(heure_denc_m)+","+dec_2_enb+",\""+days_2+"\",\""+Zone_2_veille+"\","+ heure_denc_2_h+""+format(heure_denc_2_m)+"]," +
                        "\"lum\":["+ lum_active+ ","+ auto_val+",\""+ Zone_lum+"\","+ lum_zone_1+ ","+ lum_zone_2+","+ lum_zone_3+","+ lum_zone_4+","+ lum_zone_010v+ ","+ lum_tewenty_percent+","+
                        auto_or_fixe+",\""+zones_lum_fixe+"\","+lum_start_fixe_zone_1_1+","+lum_start_fixe_zone_2_1+","+lum_start_fixe_zone_3_1+","+lum_start_fixe_zone_4_1+","+lum_fixe_start_zone_volt_1+
                        ","+lum_fixe_start_h_1+""+format(lum_fixe_start_m_1)+
                        ","+lum_fixe_start_h_2+""+format(lum_fixe_start_m_2)+","+lum_start_fixe_zone_1_2+","+lum_start_fixe_zone_2_2+","+lum_start_fixe_zone_3_2+","+lum_start_fixe_zone_4_2+","+lum_fixe_start_zone_volt_2+
                        ","+lum_fixe_end_h_1+""+format(lum_fixe_end_m_1)+","+lum_end_fixe_zone_1_1+","+lum_end_fixe_zone_2_1+","+lum_end_fixe_zone_3_1+","+lum_end_fixe_zone_4_1+","+lum_end_fixe_zone_volt_1+
                        ","+lum_fixe_end_h_2+""+format(lum_fixe_end_m_2)+","+lum_end_fixe_zone_1_2+","+lum_end_fixe_zone_2_2+","+lum_end_fixe_zone_3_2+","+lum_end_fixe_zone_4_2+","+lum_end_fixe_zone_volt_2+"]," +
                        "\"veille\":["+ veille_enb+","+pir_enc+ ","+ detec_denc_m+",\""+pir_days+"\",\""+pir_zones+"\"]," +
                        "\"cycle\":["+ cyc_enb+ ",\""+ Zone_CC+ "\",\""+ Enb_CC+ "\","+Cc_bet_times+","+ heure_p1_h+ ""+format(heure_p1_m)+","+ p1_temp+","+ heure_p2_h+""+format(heure_p2_m)+ ","+ p2_temp+","+ heure_p3_h+ ""+format(heure_p3_m)+","+ p3_temp+","+ heure_p4_h+ ""+format(heure_p4_m)+","+ p4_temp+"]" +
                        ",\"co2\":["+ co2_enb+","+ co2_email_enb+",\""+ co2_email+"\","+ co2_notify+","+ co2_zone_enb+",\""+ co2_zone+"\","+ co2_val+"]}";
        if (mConnected)
        {
            Boolean check = false;
            do {
                check = writecharacteristic(3, 0, totale);
                if (check)
                {
                    Toast.makeText(getContext(), "Configuration enregistrée !", Toast.LENGTH_SHORT).show();
                }
                if (!mConnected)
                {
                    break;
                }
            }
            while (!check);
        }
    }
    public void read_profile(){
        if(lum_active==0){switch_ajustement.setChecked(false);switch_ajustement_man.setChecked(false);}
        else
        {
            if(auto_or_fixe==0)
            {
                switch_ajustement.setChecked(false);switch_ajustement_man.setChecked(true);
            }
            else
            {
                switch_ajustement.setChecked(true);switch_ajustement_man.setChecked(false);
            }
        }
        if(veille_enb==0){switch_veille.setChecked(false);}else{switch_veille.setChecked(true);}
        if(cyc_enb==0){switch_circa.setChecked(false);}else{switch_circa.setChecked(true);}
        if(co2_enb==0){switch_co2.setChecked(false);}else{switch_co2.setChecked(true);}
        let_config=true;
        //switchColor(switch_ajustement.isChecked());
    }
    @Override
    public void onPause()
    {
        super.onPause();
        write_profile();
    }

    private void Displaydata(String data)
    {
        try
        {
            JSONObject my_profile = new JSONObject(data);
            profil_object =my_profile.getJSONObject("PROFILE_1");
            JSONArray profile = profil_object.getJSONArray("pdata");
            enc_enb=profile.getInt(0);
            enc_days=profile.getString(1);
            enc_zones=profile.getString(2);
            heure_enc_time_h = profile.getInt(3);
            heure_enc_time_m = profile.getInt(4);
            dec_enb=profile.getInt(5);
            days=profile.getString(6);
            Zone_veille=profile.getString(7);
            heure_denc_h = profile.getInt(8);
            heure_denc_m = profile.getInt(9);
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
            heure_p1_h = cycle.getInt(2);
            heure_p1_m = cycle.getInt(3);
            p1_temp = cycle.getInt(4);
            heure_p2_h = cycle.getInt(5);
            heure_p2_m = cycle.getInt(6);
            p2_temp = cycle.getInt(7);
            heure_p3_h = cycle.getInt(8);
            heure_p3_m = cycle.getInt(9);
            p3_temp = cycle.getInt(10);
            JSONArray co2 = profil_object.getJSONArray("co2");
            co2_enb = co2.getInt(0);
            co2_email_enb=co2.getInt(1);
            co2_email = co2.getString(2);
            co2_notify=co2.getInt(3);
            co2_zone_enb=co2.getInt(4);
            co2_zone = co2.getString(5);
            co2_val = co2.getInt(6);
        }
        catch (Throwable t)
        {
            Log.e("My App", "Could not parse malformed JSON: " + profile_number);
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
    public static String profile_list=
            "{" +
            "\"PROFILE_1\": {" +
            "\"pname\": \"Bureau\"," +
            "\"pdata\": [0,\"0\",\"0\", 0, 0, 0,\"0\",\"0\", 0, 0]," +
            "\"lum\": [0, 0,\"0\", 0, 0, 0, 0, 0, 0, 0, \"0\", 0, 0, 0, 0, 0, 0 , 0,0, 0, 0, 0, 0, 0, 0]," +
            "\"veille\": [0, 0, 0, \"0\", \"0\"]," +
            "\"cycle\": [0, \"0\", 0, 0, 0, 0, 0, 0, 0, 0, 0]," +
            "\"co2\": [0,0,\"exemple@mail.com\",0,0,\"0\",1000]"+
            "}}";
}
