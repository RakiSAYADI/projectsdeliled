package deliled.Applications.android.Maestro.fragment;

import android.app.AlertDialog;
import android.bluetooth.BluetoothGattCharacteristic;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import androidx.fragment.app.Fragment;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.ColorUtils;

import android.os.CountDownTimer;
import android.text.InputFilter;
import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;

import deliled.Applications.android.Maestro.R;

import static android.content.Context.MODE_PRIVATE;
import static androidx.core.graphics.ColorUtils.HSLToColor;
import static deliled.Applications.android.Maestro.MainActivity.B1;
import static deliled.Applications.android.Maestro.MainActivity.B2;
import static deliled.Applications.android.Maestro.MainActivity.B3;
import static deliled.Applications.android.Maestro.MainActivity.B4;
import static deliled.Applications.android.Maestro.MainActivity.Blanche1;
import static deliled.Applications.android.Maestro.MainActivity.Blanche2;
import static deliled.Applications.android.Maestro.MainActivity.Blanche3;
import static deliled.Applications.android.Maestro.MainActivity.Blanche4;
import static deliled.Applications.android.Maestro.MainActivity.CHAR_WRITE_LUMINOSITY;
import static deliled.Applications.android.Maestro.MainActivity.CHAR_WRITE_SYSTEM;
import static deliled.Applications.android.Maestro.MainActivity.L1;
import static deliled.Applications.android.Maestro.MainActivity.L2;
import static deliled.Applications.android.Maestro.MainActivity.L3;
import static deliled.Applications.android.Maestro.MainActivity.L4;
import static deliled.Applications.android.Maestro.MainActivity.R1;
import static deliled.Applications.android.Maestro.MainActivity.R2;
import static deliled.Applications.android.Maestro.MainActivity.R3;
import static deliled.Applications.android.Maestro.MainActivity.R4;
import static deliled.Applications.android.Maestro.MainActivity.SERVICE_WRITE;
import static deliled.Applications.android.Maestro.MainActivity.Scene_state;
import static deliled.Applications.android.Maestro.MainActivity.V1;
import static deliled.Applications.android.Maestro.MainActivity.V2;
import static deliled.Applications.android.Maestro.MainActivity.V3;
import static deliled.Applications.android.Maestro.MainActivity.V4;
import static deliled.Applications.android.Maestro.MainActivity.Zo1;
import static deliled.Applications.android.Maestro.MainActivity.Zo2;
import static deliled.Applications.android.Maestro.MainActivity.Zo3;
import static deliled.Applications.android.Maestro.MainActivity.Zo4;
import static deliled.Applications.android.Maestro.MainActivity.Zone_1;
import static deliled.Applications.android.Maestro.MainActivity.Zone_2;
import static deliled.Applications.android.Maestro.MainActivity.Zone_3;
import static deliled.Applications.android.Maestro.MainActivity.Zone_4;
import static deliled.Applications.android.Maestro.MainActivity.pause;
import static deliled.Applications.android.Maestro.MainActivity.stabilisation1;
import static deliled.Applications.android.Maestro.MainActivity.stabilisation2;
import static deliled.Applications.android.Maestro.MainActivity.stabilisation3;
import static deliled.Applications.android.Maestro.MainActivity.stabilisation4;
import static deliled.Applications.android.Maestro.MainActivity.bleReadWrite;
import static deliled.Applications.android.Maestro.MainActivity.couleur_name1;
import static deliled.Applications.android.Maestro.MainActivity.couleur_name2;
import static deliled.Applications.android.Maestro.MainActivity.couleur_name3;
import static deliled.Applications.android.Maestro.MainActivity.couleur_name4;
import static deliled.Applications.android.Maestro.MainActivity.mBluetoothLeService;
import static deliled.Applications.android.Maestro.MainActivity.Favoris;
import static deliled.Applications.android.Maestro.MainActivity.mConnected;
import static deliled.Applications.android.Maestro.MainActivity.mGattCharacteristics;
import static deliled.Applications.android.Maestro.MainActivity.state;
import static deliled.Applications.android.Maestro.ajustement_luminosite.isHexNumber;
import static deliled.Applications.android.Maestro.fragment.DeviceControFragment.Acceuil_isactive;

public class AmbiancesFragment extends Fragment {
    public BluetoothGattCharacteristic mNotifyCharacteristic;

    private int redvalue ,greenvalue,bluevalue;

    private TextView text_red,text_green,text_blue;

    private ToggleButton FAV1,FAV2,FAV3,FAV4,fav_ZONE1,fav_ZONE2,fav_ZONE3,fav_ZONE4;

    private SeekBar rEd,grEEn,blEu,Blanche,Stabilisations,fav_lum;

    private Button sauve,renommer,supprimer;

    private View view,view_ambiances;

    private GradientDrawable shape =  new GradientDrawable();

    boolean saving_fav;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.ambiances_fragment, container, false);
        Acceuil_isactive=false;
        read_text_json();
        saving_fav=true;
        redvalue = 0;bluevalue = 0;greenvalue = 0;
        supprimer = view.findViewById(R.id.supprimmer);
        blEu=view.findViewById(R.id.BLEU);
        grEEn=view.findViewById(R.id.GREEN);
        rEd=view.findViewById(R.id.RED);
        FAV1=view.findViewById(R.id.Fav1);
        FAV2=view.findViewById(R.id.Fav2);
        FAV3=view.findViewById(R.id.Fav3);
        FAV4=view.findViewById(R.id.Fav4);
        view_ambiances=view.findViewById(R.id.view_ambiance);
        fav_ZONE1=view.findViewById(R.id.ZONE1);
        fav_ZONE2=view.findViewById(R.id.ZONE2);
        fav_ZONE3=view.findViewById(R.id.ZONE3);
        fav_ZONE4=view.findViewById(R.id.ZONE4);
        fav_lum=view.findViewById(R.id.luminositefav);
        sauve=view.findViewById(R.id.sauveguarde);
        renommer=view.findViewById(R.id.renommer);
        Stabilisations=view.findViewById(R.id.stabilisationfav);
        Blanche=view.findViewById(R.id.blanchefav);
        text_red=view.findViewById(R.id.textview);
        text_green=view.findViewById(R.id.textview2);
        text_blue=view.findViewById(R.id.textview3);
        blEu.setMax(255);
        grEEn.setMax(255);
        rEd.setMax(255);
        redvalue=0;
        greenvalue=0;
        bluevalue=0;
        shape.setCornerRadius( 75 );
        read_colors();
        FAV1.setTextColor(ContextCompat.getColor(getContext(),R.color.White));
        FAV2.setTextColor(ContextCompat.getColor(getContext(),R.color.White));
        FAV3.setTextColor(ContextCompat.getColor(getContext(),R.color.White));
        FAV4.setTextColor(ContextCompat.getColor(getContext(),R.color.White));
        sauve.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saving_fav();
            }
        });
        supprimer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
                builder.setMessage("Êtes-vous sur de vouloir supprimer ces réglages ? Cette action est irréversible.")
                        .setTitle("Attention")
                        .setCancelable(false)
                        .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                couleur_name1="Ambiance1";
                                couleur_name2="Ambiance2";
                                couleur_name3="Ambiance3";
                                couleur_name4="Ambiance4";
                                R1=0;R2=0;R3=0;R4=0;
                                V1=0;V2=0;V3=0;V4=0;
                                B1=0;B2=0;B3=0;B4=0;
                                L1=50;L2=50;L3=50;L4=50;
                                Zo1="f";Zo2="f";Zo3="f";Zo4="f";
                                stabilisation1=100;stabilisation2=100;stabilisation3=100;stabilisation4=100;
                                save("Favoris.txt",Favoris);
                                rEd.setProgress(0);
                                grEEn.setProgress(0);
                                blEu.setProgress(0);
                                fav_lum.setProgress(50);
                                fav_ZONE1.setChecked(false);
                                fav_ZONE2.setChecked(false);
                                fav_ZONE3.setChecked(false);
                                fav_ZONE4.setChecked(false);
                                Stabilisations.setProgress(50);
                                Blanche.setProgress(50);
                                Toast.makeText(getContext(), "les paramètres sont par défauts pour le mode expert ", Toast.LENGTH_LONG).show();
                                read_colors();
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
        FAV1.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(FAV1.isChecked()) {
                    FAV3.setChecked(false);
                    FAV2.setChecked(false);
                    FAV4.setChecked(false);
                }
                if(!isHexNumber(Zo1))
                {
                    Zo1="0";
                }
                int zone = Integer.parseInt(Zo1,16);
                int z1 = zone/8;
                int z2 = zone%8/4;
                int z3 = zone%4/2;
                int z4 = zone%2;
                if (z4==0){ fav_ZONE1.setChecked(false);}else {fav_ZONE1.setChecked(true); }
                if (z3==0){ fav_ZONE2.setChecked(false);}else {fav_ZONE2.setChecked(true); }
                if (z2==0){ fav_ZONE3.setChecked(false);}else {fav_ZONE3.setChecked(true); }
                if (z1==0){ fav_ZONE4.setChecked(false);}else {fav_ZONE4.setChecked(true); }
                white_or_rbg(Blanche1,R1,V1,B1);
                Stabilisations.setProgress(stabilisation1);
                fav_lum.setProgress(L1);
                shape.setColor(white_selection(Blanche1,R1,V1,B1));
                view_ambiances.setBackground(shape);
                if(FAV1.isChecked())
                {
                    if(Scene_state==1)
                    {
                        Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                    }else if (state==0)
                    {
                        int z_amb_1,z_amb_2,z_amb_3,z_amb_4;
                        if (fav_ZONE1.isChecked()){z_amb_1=1;}else {z_amb_1=0;}
                        if (fav_ZONE2.isChecked()){z_amb_2=1;}else {z_amb_2=0;}
                        if (fav_ZONE3.isChecked()){z_amb_3=1;}else {z_amb_3=0;}
                        if (fav_ZONE4.isChecked()){z_amb_4=1;}else {z_amb_4=0;}
                        Zo1 =Integer.toString((z_amb_4*8)+(z_amb_3*4)+(z_amb_2*2)+z_amb_1, 16);
                        stabilisation1 = Stabilisations.getProgress();
                        Blanche1=Blanche.getProgress();
                        R1 = rEd.getProgress();
                        V1 = grEEn.getProgress();
                        B1 = blEu.getProgress();
                        L1 = fav_lum.getProgress();
                        String favoris1 = "{\"Favoris\":[" + stabilisation1 + "," + R1 + "," + V1 + "," + B1 + ",\"" + Zo1 + "\"," + L1 + ","+Blanche1+"]}";
                        Boolean check;
                        do {
                            check=writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, favoris1);
                            if(!mConnected){break;}
                        } while (!check);
                        if (check)
                        {
                            FAV2.setEnabled(false);
                            FAV4.setEnabled(false);
                            FAV3.setEnabled(false);
                            Toast.makeText(getContext(), "Chargement de l'ambiance :"+couleur_name1, Toast.LENGTH_SHORT).show();
                            pause(700);
                            FAV2.setEnabled(true);
                            FAV4.setEnabled(true);
                            FAV3.setEnabled(true);
                        }
                    }
                    else
                    {
                        Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                    }
                }
            }
        });
        FAV2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(FAV2.isChecked()) {
                    FAV3.setChecked(false);
                    FAV1.setChecked(false);
                    FAV4.setChecked(false);
                }
                if(!isHexNumber(Zo2))
                {
                    Zo2="0";
                }
                int zone = Integer.parseInt(Zo2,16);
                int z1 = zone/8;
                int z2 = zone%8/4;
                int z3 = zone%4/2;
                int z4 = zone%2;
                if (z4==0){fav_ZONE1.setChecked(false);}else{fav_ZONE1.setChecked(true);}
                if (z3==0){fav_ZONE2.setChecked(false);}else{fav_ZONE2.setChecked(true);}
                if (z2==0){fav_ZONE3.setChecked(false);}else{fav_ZONE3.setChecked(true);}
                if (z1==0){fav_ZONE4.setChecked(false);}else{fav_ZONE4.setChecked(true);}
                white_or_rbg(Blanche2,R2,V2,B2);
                Stabilisations.setProgress(stabilisation2);
                fav_lum.setProgress(L2);
                shape.setColor(white_selection(Blanche2,R2,V2,B2));
                view_ambiances.setBackground(shape);
                if(FAV2.isChecked()){
                    if(Scene_state==1)
                    {
                        Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                    }else if (state==0)
                    {
                        int z_amb_1,z_amb_2,z_amb_3,z_amb_4;
                        if (fav_ZONE1.isChecked()){z_amb_1=1;}else {z_amb_1=0;}
                        if (fav_ZONE2.isChecked()){z_amb_2=1;}else {z_amb_2=0;}
                        if (fav_ZONE3.isChecked()){z_amb_3=1;}else {z_amb_3=0;}
                        if (fav_ZONE4.isChecked()){z_amb_4=1;}else {z_amb_4=0;}
                        Zo2 =Integer.toString((z_amb_4*8)+(z_amb_3*4)+(z_amb_2*2)+z_amb_1, 16);
                        stabilisation2 = Stabilisations.getProgress();
                        Blanche2=Blanche.getProgress();
                        R2 = rEd.getProgress();
                        V2 = grEEn.getProgress();
                        B2 = blEu.getProgress();
                        L2=fav_lum.getProgress();
                        String favoris2 = "{\"Favoris\":[" + stabilisation2 + "," + R2 + "," + V2 + "," + B2 + ",\"" + Zo2 + "\"," + L2 + ","+Blanche2+"]}";
                        Boolean check;
                        do {
                            check=writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, favoris2);
                            if(!mConnected){break;}
                        } while (!check);
                        if(check)
                        {
                            FAV4.setEnabled(false);
                            FAV1.setEnabled(false);
                            FAV3.setEnabled(false);
                            Toast.makeText(getContext(), "Chargement de l'ambiance :"+couleur_name2, Toast.LENGTH_SHORT).show();
                            pause(700);
                            FAV4.setEnabled(true);
                            FAV1.setEnabled(true);
                            FAV3.setEnabled(true);
                        }
                    }
                    else
                    {
                        Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                    }

                }
            }
        });
        FAV3.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(FAV3.isChecked()) {
                    FAV2.setChecked(false);
                    FAV1.setChecked(false);
                    FAV4.setChecked(false);
                }
                if(!isHexNumber(Zo3))
                {
                    Zo3="0";
                }
                int zone = Integer.parseInt(Zo3,16);
                int z1 = zone/8;
                int z2 = zone%8/4;
                int z3 = zone%4/2;
                int z4 = zone%2;
                if (z4==0){ fav_ZONE1.setChecked(false);}else {fav_ZONE1.setChecked(true); }
                if (z3==0){ fav_ZONE2.setChecked(false);}else {fav_ZONE2.setChecked(true); }
                if (z2==0){ fav_ZONE3.setChecked(false);}else {fav_ZONE3.setChecked(true); }
                if (z1==0){ fav_ZONE4.setChecked(false);}else {fav_ZONE4.setChecked(true); }
                white_or_rbg(Blanche3,R3,V3,B3);
                Stabilisations.setProgress(stabilisation3);
                fav_lum.setProgress(L3);
                shape.setColor(white_selection(Blanche3,R3,V3,B3));
                view_ambiances.setBackground(shape);
                if(FAV3.isChecked())
                {
                    if(Scene_state==1)
                    {
                        Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                    }else if (state==0)
                    {
                        int z_amb_1,z_amb_2,z_amb_3,z_amb_4;
                        if (fav_ZONE1.isChecked()){z_amb_1=1;}else {z_amb_1=0;}
                        if (fav_ZONE2.isChecked()){z_amb_2=1;}else {z_amb_2=0;}
                        if (fav_ZONE3.isChecked()){z_amb_3=1;}else {z_amb_3=0;}
                        if (fav_ZONE4.isChecked()){z_amb_4=1;}else {z_amb_4=0;}
                        Zo3 =Integer.toString((z_amb_4*8)+(z_amb_3*4)+(z_amb_2*2)+z_amb_1, 16);
                        stabilisation3 = Stabilisations.getProgress();
                        Blanche3=Blanche.getProgress();
                        R3 = rEd.getProgress();
                        V3 = grEEn.getProgress();
                        B3 = blEu.getProgress();
                        L3=fav_lum.getProgress();
                        String favoris3 = "{\"Favoris\":[" + stabilisation3 + "," + R3 + "," + V3 + "," + B3 + ",\"" + Zo3 + "\"," + L3 + ","+Blanche3+"]}";
                        Boolean check;
                        do {
                            check=writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, favoris3);
                            if(!mConnected){break;}
                        } while (!check);
                        if(check)
                        {
                            FAV2.setEnabled(false);
                            FAV1.setEnabled(false);
                            FAV4.setEnabled(false);
                            Toast.makeText(getContext(), "Chargement de l'ambiance :"+couleur_name3, Toast.LENGTH_SHORT).show();
                            pause(700);
                            FAV2.setEnabled(true);
                            FAV1.setEnabled(true);
                            FAV4.setEnabled(true);
                        }
                    }
                    else
                    {
                        Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                    }
                }
            }
        });
        FAV4.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if(FAV4.isChecked()) {
                    FAV2.setChecked(false);
                    FAV1.setChecked(false);
                    FAV3.setChecked(false);
                }

                if(!isHexNumber(Zo4))
                {
                    Zo4="0";
                }
                int zone = Integer.parseInt(Zo4,16);
                int z1 = zone/8;
                int z2 = zone%8/4;
                int z3 = zone%4/2;
                int z4 = zone%2;
                if (z4==0){ fav_ZONE1.setChecked(false);}else {fav_ZONE1.setChecked(true); }
                if (z3==0){ fav_ZONE2.setChecked(false);}else {fav_ZONE2.setChecked(true); }
                if (z2==0){ fav_ZONE3.setChecked(false);}else {fav_ZONE3.setChecked(true); }
                if (z1==0){ fav_ZONE4.setChecked(false);}else {fav_ZONE4.setChecked(true); }
                white_or_rbg(Blanche4,R4,V4,B4);
                Stabilisations.setProgress(stabilisation4);
                fav_lum.setProgress(L4);
                shape.setColor(white_selection(Blanche4,R4,V4,B4));
                view_ambiances.setBackground(shape);
                if(FAV4.isChecked())
                {
                    if(Scene_state==1)
                    {
                        Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
                    }else if (state==0)
                    {
                        int z_amb_1,z_amb_2,z_amb_3,z_amb_4;
                        if (fav_ZONE1.isChecked()){z_amb_1=1;}else {z_amb_1=0;}
                        if (fav_ZONE2.isChecked()){z_amb_2=1;}else {z_amb_2=0;}
                        if (fav_ZONE3.isChecked()){z_amb_3=1;}else {z_amb_3=0;}
                        if (fav_ZONE4.isChecked()){z_amb_4=1;}else {z_amb_4=0;}
                        Zo4 =Integer.toString((z_amb_4*8)+(z_amb_3*4)+(z_amb_2*2)+z_amb_1, 16);
                        stabilisation4 = Stabilisations.getProgress();
                        Blanche4=Blanche.getProgress();
                        R4 = rEd.getProgress();
                        V4 = grEEn.getProgress();
                        B4 = blEu.getProgress();
                        L4=fav_lum.getProgress();
                        String favoris4 = "{\"Favoris\":[" + stabilisation4 + "," + R4 + "," + V4 + "," + B4 + ",\"" + Zo4 + "\"," + L4 + ","+Blanche4+"]}";
                        Boolean check;
                        do {

                            check=writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, favoris4);
                            if(!mConnected){break;}
                        } while (!check);
                        if(check)
                        {
                            FAV2.setEnabled(false);
                            FAV1.setEnabled(false);
                            FAV3.setEnabled(false);
                            Toast.makeText(getContext(), "Chargement de l'ambiance :"+couleur_name4, Toast.LENGTH_SHORT).show();
                            pause(700);
                            FAV2.setEnabled(true);
                            FAV1.setEnabled(true);
                            FAV3.setEnabled(true);
                        }
                    }
                    else
                    {
                        Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
                    }

                }
            }
        });
        renommer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                LinearLayout layout = new LinearLayout(getContext());
                layout.setOrientation(LinearLayout.VERTICAL);

                LinearLayout layout2 = new LinearLayout(getContext());
                layout2.setOrientation(LinearLayout.HORIZONTAL);
                final TextView prof_col = new TextView(getContext());
                String col="Ambience 1 : ";
                prof_col.setText(col);
                final LinearLayout.LayoutParams lparam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                prof_col.setTextSize(TypedValue.COMPLEX_UNIT_SP,18);
                layout2.addView(prof_col);

                final EditText couleur1 = new EditText(getContext());
                couleur1.setHint("Nom du Ambience 1");
                couleur1.setMaxLines(1);
                couleur1.setFilters(new InputFilter[] {new InputFilter.LengthFilter(15)});
                couleur1.setText(couleur_name1);
                couleur1.setInputType(EditorInfo.TYPE_CLASS_TEXT);
                couleur1.setLayoutParams(lparam);
                layout2.addView(couleur1);
                layout.addView(layout2);

                LinearLayout layout3 = new LinearLayout(getContext());
                layout3.setOrientation(LinearLayout.HORIZONTAL);
                final TextView prof_col2 = new TextView(getContext());
                String col2="Ambience 2 : ";
                prof_col2.setText(col2);
                prof_col2.setTextSize(TypedValue.COMPLEX_UNIT_SP,18);
                layout3.addView(prof_col2);

                final EditText couleur2 = new EditText(getContext());
                couleur2.setHint("Nom du Ambience 2");
                couleur2.setMaxLines(1);
                couleur2.setInputType(EditorInfo.TYPE_CLASS_TEXT);
                couleur2.setFilters(new InputFilter[] {new InputFilter.LengthFilter(15)});
                couleur2.setText(couleur_name2);
                couleur2.setLayoutParams(lparam);
                layout3.addView(couleur2);
                layout.addView(layout3);

                LinearLayout layout4 = new LinearLayout(getContext());
                layout4.setOrientation(LinearLayout.HORIZONTAL);
                final TextView prof_col3 = new TextView(getContext());
                String col3="Ambience 3 : ";
                prof_col3.setText(col3);
                prof_col3.setTextSize(TypedValue.COMPLEX_UNIT_SP,18);
                layout4.addView(prof_col3);

                final EditText couleur3 = new EditText(getContext());
                couleur3.setHint("Nom du Ambience 3");
                couleur3.setMaxLines(1);
                couleur3.setInputType(EditorInfo.TYPE_CLASS_TEXT);
                couleur3.setFilters(new InputFilter[] {new InputFilter.LengthFilter(15)});
                couleur3.setText(couleur_name3);
                couleur3.setLayoutParams(lparam);
                layout4.addView(couleur3);
                layout.addView(layout4);

                LinearLayout layout5 = new LinearLayout(getContext());
                layout5.setOrientation(LinearLayout.HORIZONTAL);
                final TextView prof_col4 = new TextView(getContext());
                String col4="Ambience 4 : ";
                prof_col4.setText(col4);
                prof_col4.setTextSize(TypedValue.COMPLEX_UNIT_SP,18);
                layout5.addView(prof_col4);

                final EditText couleur4 = new EditText(getContext());
                couleur4.setHint("Nom du Ambience 4");
                couleur4.setMaxLines(1);
                couleur4.setInputType(EditorInfo.TYPE_CLASS_TEXT);
                couleur4.setFilters(new InputFilter[] {new InputFilter.LengthFilter(15)});
                couleur4.setText(couleur_name4);
                couleur4.setLayoutParams(lparam);
                layout5.addView(couleur4);
                layout.addView(layout5);

                final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
                builder.setMessage("Changer les noms des Ambiances :(max 15 caractères) ")
                        .setTitle("Réglages")
                        .setCancelable(false)
                        .setView(layout)
                        .setPositiveButton("Oui", new DialogInterface.OnClickListener() {
                            public void onClick(final DialogInterface dialog, final int id) {
                                couleur_name1=couleur1.getText().toString();
                                couleur_name2=couleur2.getText().toString();
                                couleur_name3=couleur3.getText().toString();
                                couleur_name4=couleur4.getText().toString();
                                saving_fav=false;
                                write_text_json();
                                read_colors();
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
        rEd.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue=0;
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if ((state==0&Scene_state==0&(FAV1.isChecked()|FAV2.isChecked()|FAV3.isChecked()|FAV4.isChecked()))&fromUser) {
                    int z1, z2, z3, z4;
                    saving_fav=false;
                    if (fav_ZONE1.isChecked()) { z1 = 1; } else { z1 = 0; }
                    if (fav_ZONE2.isChecked()) { z2 = 1; } else { z2 = 0; }
                    if (fav_ZONE3.isChecked()) { z3 = 1; } else { z3 = 0; }
                    if (fav_ZONE4.isChecked()) { z4 = 1; } else { z4 = 0; }
                    String Zone_amb = Integer.toString((z4 * 8) + (z3 * 4) + (z2 * 2) + z1, 16);
                    int rbg = progress*0x10000 + grEEn.getProgress() * 0x100 + blEu.getProgress();
                    String rgb = "{\"rgb\":[" + rbg + "," + Zone_amb + "]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, rgb);
                }
                progressChangedValue=progress;
                redvalue=progressChangedValue;
                View view_red = view.findViewById(R.id.view_ambiance);
                GradientDrawable shape =  new GradientDrawable();
                shape.setCornerRadius( 75 );
                //view.setBackgroundColor(envelope.getColor());
                shape.setColor(Color.rgb(redvalue,greenvalue,bluevalue));
                view_red.setBackground(shape);
                progressChangedValue=(progressChangedValue*100)/255;
                String lim = ""+progressChangedValue+"%";
                text_red.setText(lim);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        grEEn.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue=0;
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if ((state==0&Scene_state==0&(FAV1.isChecked()|FAV2.isChecked()|FAV3.isChecked()|FAV4.isChecked()))&fromUser) {
                    int z1, z2, z3, z4;
                    saving_fav=false;
                    if (fav_ZONE1.isChecked()){z1=1;}else{z1=0;}
                    if (fav_ZONE2.isChecked()){z2=1;}else{z2=0;}
                    if (fav_ZONE3.isChecked()){z3=1;}else{z3=0;}
                    if (fav_ZONE4.isChecked()){z4=1;}else{z4=0;}
                    String Zone_amb = Integer.toString((z4 * 8) + (z3 * 4) + (z2 * 2) + z1, 16);
                    int rbg = rEd.getProgress() * 0x10000 + progress * 0x100 + blEu.getProgress();
                    String rgb = "{\"rgb\":[" + rbg + "," + Zone_amb + "]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, rgb);
                }
                progressChangedValue=progress;
                View view_green = view.findViewById(R.id.view_ambiance);
                greenvalue=progressChangedValue;
                GradientDrawable shape =  new GradientDrawable();
                shape.setCornerRadius( 75 );
                //view.setBackgroundColor(envelope.getColor());
                shape.setColor(Color.rgb(redvalue,greenvalue,bluevalue));
                view_green.setBackground(shape);
                progressChangedValue=(progressChangedValue*100)/255;
                String lim = ""+progressChangedValue+"%";
                text_green.setText(lim);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        blEu.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int progressChangedValue=0;
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if ((state==0&Scene_state==0&(FAV1.isChecked()|FAV2.isChecked()|FAV3.isChecked()|FAV4.isChecked()))&fromUser) {
                    int z1, z2, z3, z4;
                    saving_fav=false;
                    if (fav_ZONE1.isChecked()) { z1 = 1; } else { z1 = 0; }
                    if (fav_ZONE2.isChecked()) { z2 = 1; } else { z2 = 0; }
                    if (fav_ZONE3.isChecked()) { z3 = 1; } else { z3 = 0; }
                    if (fav_ZONE4.isChecked()) { z4 = 1; } else { z4 = 0; }
                    String Zone_amb = Integer.toString((z4 * 8) + (z3 * 4) + (z2 * 2) + z1, 16);
                    int rbg = rEd.getProgress() * 0x10000 + grEEn.getProgress() * 0x100 + progress;
                    String rgb = "{\"rgb\":[" + rbg + "," + Zone_amb + "]}";
                    writecharacteristic(SERVICE_WRITE, CHAR_WRITE_LUMINOSITY, rgb);
                }
                progressChangedValue=progress;
                View view_blue = view.findViewById(R.id.view_ambiance);
                bluevalue=progressChangedValue;
                GradientDrawable shape =  new GradientDrawable();
                shape.setCornerRadius( 75 );
                //view.setBackgroundColor(envelope.getColor());
                shape.setColor(Color.rgb(redvalue,greenvalue,bluevalue));
                view_blue.setBackground(shape);
                progressChangedValue=(progressChangedValue*100)/255;
                String lim = ""+progressChangedValue+"%";
                text_blue.setText(lim);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        fav_lum.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if ((state==0&Scene_state==0&(FAV1.isChecked()|FAV2.isChecked()|FAV3.isChecked()|FAV4.isChecked()))&fromUser)
                {
                    saving_fav=false;
                    int z1,z2,z3,z4;
                    if (fav_ZONE1.isChecked()){z1=1;}else {z1=0;}
                    if (fav_ZONE2.isChecked()){z2=1;}else {z2=0;}
                    if (fav_ZONE3.isChecked()){z3=1;}else {z3=0;}
                    if (fav_ZONE4.isChecked()){z4=1;}else {z4=0;}
                    String Zone_amb =Integer.toString((z4*8)+(z3*4)+(z2*2)+z1, 16);
                    String blanche = "{\"light\":[7,"+progress+","+Zone_amb+"]}";
                    writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY,blanche);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        Stabilisations.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if ((state==0&Scene_state==0&(FAV1.isChecked()|FAV2.isChecked()|FAV3.isChecked()|FAV4.isChecked()))&fromUser)
                {
                    saving_fav=false;
                    int z1,z2,z3,z4;
                    if (fav_ZONE1.isChecked()){z1=1;}else {z1=0;}
                    if (fav_ZONE2.isChecked()){z2=1;}else {z2=0;}
                    if (fav_ZONE3.isChecked()){z3=1;}else {z3=0;}
                    if (fav_ZONE4.isChecked()){z4=1;}else {z4=0;}
                    String Zone_amb =Integer.toString((z4*8)+(z3*4)+(z2*2)+z1, 16);
                    String blanche = "{\"light\":[9,"+progress+","+Zone_amb+"]}";
                    writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY,blanche);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        Blanche.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if ((state==0&Scene_state==0&(FAV1.isChecked()|FAV2.isChecked()|FAV3.isChecked()|FAV4.isChecked()))&fromUser)
                {
                    saving_fav=false;
                    int z1,z2,z3,z4;
                    if (fav_ZONE1.isChecked()){z1=1;}else {z1=0;}
                    if (fav_ZONE2.isChecked()){z2=1;}else {z2=0;}
                    if (fav_ZONE3.isChecked()){z3=1;}else {z3=0;}
                    if (fav_ZONE4.isChecked()){z4=1;}else {z4=0;}
                    String Zone_amb =Integer.toString((z4*8)+(z3*4)+(z2*2)+z1, 16);
                    String blanche = "{\"light\":[8,"+progress+","+Zone_amb+"]}";
                    writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY,blanche);
                    View viewBlanche = view.findViewById(R.id.view_ambiance);
                    GradientDrawable shape =  new GradientDrawable();
                    shape.setCornerRadius( 75 );
                    if(progress<=50){
                        shape.setColor(Color.rgb(155+(progress*2),255,255));
                    } else{
                        shape.setColor(Color.rgb(255,255,255-((progress-50)*2)));
                    }
                    viewBlanche.setBackground(shape);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });
        fav_ZONE1.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (buttonView.isPressed()) {
                    // do something related to user click/tap
                    sending_on_off(fav_ZONE1,"1");
                }
            }
        });
        fav_ZONE2.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (buttonView.isPressed()) {
                    // do something related to user click/tap
                    sending_on_off(fav_ZONE2,"2");
                }
            }
        });
        fav_ZONE3.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (buttonView.isPressed()) {
                    // do something related to user click/tap
                    sending_on_off(fav_ZONE3,"4");
                }
            }
        });
        fav_ZONE4.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (buttonView.isPressed()) {
                    // do something related to user click/tap
                    sending_on_off(fav_ZONE4,"8");
                }
            }
        });
        return view;
    }
    private void saving_fav()
    {
        saving_fav=true;
        if (FAV1.isChecked())
        {
            int z1,z2,z3,z4;
            if (fav_ZONE1.isChecked()){z1=1;}else {z1=0;}
            if (fav_ZONE2.isChecked()){z2=1;}else {z2=0;}
            if (fav_ZONE3.isChecked()){z3=1;}else {z3=0;}
            if (fav_ZONE4.isChecked()){z4=1;}else {z4=0;}
            Zo1 =Integer.toString((z4*8)+(z3*4)+(z2*2)+z1, 16);
            couleur_name1 =FAV1.getText().toString();
            stabilisation1 = Stabilisations.getProgress();
            Blanche1=Blanche.getProgress();
            R1 = rEd.getProgress();
            V1 = grEEn.getProgress();
            B1 = blEu.getProgress();
            L1=fav_lum.getProgress();
            if (Zo1.equals("0"))
            {
                Toast.makeText(getContext(), "Vous n'avez sélectionné aucune zone !", Toast.LENGTH_SHORT).show();
            }
            else {
                Toast.makeText(getContext(), "Votre Ambiance a bien été enregistrée !", Toast.LENGTH_SHORT).show();
                write_text_json();
            }
        }
        else
        if (FAV2.isChecked())
        {
            int z1,z2,z3,z4;
            if (fav_ZONE1.isChecked()){z1=1;}else {z1=0;}
            if (fav_ZONE2.isChecked()){z2=1;}else {z2=0;}
            if (fav_ZONE3.isChecked()){z3=1;}else {z3=0;}
            if (fav_ZONE4.isChecked()){z4=1;}else {z4=0;}
            Zo2 =Integer.toString((z4*8)+(z3*4)+(z2*2)+z1, 16);
            couleur_name2 =FAV2.getText().toString();
            stabilisation2 = Stabilisations.getProgress();
            Blanche2=Blanche.getProgress();
            R2 = rEd.getProgress();
            V2 = grEEn.getProgress();
            B2 = blEu.getProgress();
            L2=fav_lum.getProgress();
            if (Zo2.equals("0"))
            {
                Toast.makeText(getContext(), "Vous n'avez sélectionné aucune zone ! ", Toast.LENGTH_SHORT).show();
            }
            else {
                Toast.makeText(getContext(), "Votre Ambiance a bien été enregistrée ! ", Toast.LENGTH_SHORT).show();
                write_text_json();
            }
        }else
        if (FAV3.isChecked())
        {
            int z1,z2,z3,z4;
            if (fav_ZONE1.isChecked()){z1=1;}else {z1=0;}
            if (fav_ZONE2.isChecked()){z2=1;}else {z2=0;}
            if (fav_ZONE3.isChecked()){z3=1;}else {z3=0;}
            if (fav_ZONE4.isChecked()){z4=1;}else {z4=0;}
            Zo3 =Integer.toString((z4*8)+(z3*4)+(z2*2)+z1, 16);
            couleur_name3 =FAV3.getText().toString();
            stabilisation3 = Stabilisations.getProgress();
            Blanche3=Blanche.getProgress();
            R3 = rEd.getProgress();
            V3 = grEEn.getProgress();
            B3 = blEu.getProgress();
            L3=fav_lum.getProgress();
            if (Zo3.equals("0"))
            {
                Toast.makeText(getContext(), "Vous n'avez sélectionné aucune zone ! ", Toast.LENGTH_SHORT).show();
            }
            else {
                Toast.makeText(getContext(), "Votre Ambiance a bien été enregistrée ! ", Toast.LENGTH_SHORT).show();
                write_text_json();
            }
        }else
        if (FAV4.isChecked())
        {
            int z1,z2,z3,z4;
            if (fav_ZONE1.isChecked()){z1=1;}else {z1=0;}
            if (fav_ZONE2.isChecked()){z2=1;}else {z2=0;}
            if (fav_ZONE3.isChecked()){z3=1;}else {z3=0;}
            if (fav_ZONE4.isChecked()){z4=1;}else {z4=0;}
            Zo4 =Integer.toString((z4*8)+(z3*4)+(z2*2)+z1, 16);
            couleur_name4 =FAV4.getText().toString();
            stabilisation4 = Stabilisations.getProgress();
            Blanche4=Blanche.getProgress();
            R4 = rEd.getProgress();
            V4 = grEEn.getProgress();
            B4 = blEu.getProgress();
            L4=fav_lum.getProgress();
            if (Zo4.equals("0"))
            {
                Toast.makeText(getContext(), "Vous n'avez sélectionné aucune zone ! ", Toast.LENGTH_SHORT).show();
            }
            else {
                Toast.makeText(getContext(), "Votre Ambiance a bien été enregistrée ! ", Toast.LENGTH_SHORT).show();
                write_text_json();
            }
        }
        else {
            Toast.makeText(getContext(), "Veuillez sélectionner un profil pour le sauvegarder !", Toast.LENGTH_SHORT).show();
        }
        read_colors();
    }
    private void read_text_json(){
        if (!fileExists(getActivity().getApplicationContext(),"Favoris.txt"))
        {
            save("Favoris.txt",Favoris);
        }
        String les_favoris=load("Favoris.txt");
        try {
            JSONObject colors =new JSONObject(les_favoris);
            JSONArray color1 = colors.getJSONArray("couleur1");
            couleur_name1 = color1.getString(0);
            stabilisation1 = color1.getInt(1);
            R1 = color1.getInt(2);
            V1 = color1.getInt(3);
            B1 = color1.getInt(4);
            Zo1 =color1.getString(5);
            L1 =color1.getInt(6);
            Blanche1 =color1.getInt(7);
            JSONArray color2 = colors.getJSONArray("couleur2");
            couleur_name2 = color2.getString(0);
            stabilisation2 = color2.getInt(1);
            R2 = color2.getInt(2);
            V2 = color2.getInt(3);
            B2 = color2.getInt(4);
            Zo2 =color2.getString(5);
            L2 =color2.getInt(6);
            Blanche2 =color2.getInt(7);
            JSONArray color3 = colors.getJSONArray("couleur3");
            couleur_name3 = color3.getString(0);
            stabilisation3 = color3.getInt(1);
            R3 = color3.getInt(2);
            V3 = color3.getInt(3);
            B3 = color3.getInt(4);
            Zo3 =color3.getString(5);
            L3 =color3.getInt(6);
            Blanche3 =color3.getInt(7);
            JSONArray color4 = colors.getJSONArray("couleur4");
            couleur_name4 = color4.getString(0);
            stabilisation4 = color4.getInt(1);
            R4 = color4.getInt(2);
            V4 = color4.getInt(3);
            B4 = color4.getInt(4);
            Zo4 =color4.getString(5);
            L4 =color4.getInt(6);
            Blanche4 =color4.getInt(7);
        }catch (Throwable t) {
            Log.e("My App", "Could not parse malformed JSON: " + les_favoris);
            save("Favoris.txt",Favoris);
            couleur_name1="Ambiance1";couleur_name2="Ambiance2";couleur_name3="Ambiance3";couleur_name4="Ambiance4";
            stabilisation1=100;stabilisation2=100;stabilisation3=100;stabilisation4=100;
            R1=0;R2=0;R3=0;R4=0;
            V1=0;V2=0;V3=0;V4=0;
            B1=0;B2=0;B3=0;B4=0;
            Blanche1=0;Blanche2=0;Blanche3=0;Blanche4=0;
            Zo1="f";Zo2="f";Zo3="f";Zo4="f";
            L1=0;L2=0;L3=0;L4=0;
        }
    }
    private void write_text_json()
    {
        JSONArray couleur1 = new JSONArray();
        couleur1.put(couleur_name1);couleur1.put(stabilisation1);couleur1.put(R1);
        couleur1.put(V1);couleur1.put(B1);couleur1.put(Zo1);couleur1.put(L1);couleur1.put(Blanche1);
        JSONArray couleur2 = new JSONArray();
        couleur2.put(couleur_name2);couleur2.put(stabilisation2);couleur2.put(R2);
        couleur2.put(V2);couleur2.put(B2);couleur2.put(Zo2);couleur2.put(L2);couleur2.put(Blanche2);
        JSONArray couleur3 = new JSONArray();
        couleur3.put(couleur_name3);couleur3.put(stabilisation3);couleur3.put(R3);
        couleur3.put(V3);couleur3.put(B3);couleur3.put(Zo3);couleur3.put(L3);couleur3.put(Blanche3);
        JSONArray couleur4 = new JSONArray();
        couleur4.put(couleur_name4);couleur4.put(stabilisation4);couleur4.put(R4);
        couleur4.put(V4);couleur4.put(B4);couleur4.put(Zo4);couleur4.put(L4);couleur4.put(Blanche4);
        try {
            JSONObject favoris = new JSONObject();
            favoris.put("couleur1",couleur1);
            favoris.put("couleur2",couleur2);
            favoris.put("couleur3",couleur3);
            favoris.put("couleur4",couleur4);
            save("Favoris.txt",favoris.toString());
            Log.i("My App", "favoris : " + favoris.toString());
            writecharacteristic(SERVICE_WRITE,CHAR_WRITE_SYSTEM,favoris.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public static int white_selection(int blanche,int red,int green,int bleu){
        int color;
        if (red == 0 & green == 0 & bleu == 0) {
            if (blanche==50){
                color=Color.rgb(255,255,255);
            }else if(blanche<50){
                color=Color.rgb(155+(blanche*2),255,255);
            } else{
                color=Color.rgb(255,255,255-blanche);
            }
        }else {
            color=Color.rgb(red,green,bleu);
        }
        return color;
    }

    public void white_or_rbg(int blanche,int red,int green,int bleu)
    {
        if (red == 0 & green == 0 & bleu == 0)
        {
            rEd.setProgress(0);
            grEEn.setProgress(0);
            blEu.setProgress(0);
            Blanche.setProgress(blanche);
        }
        else {
            Blanche.setProgress(50);
            rEd.setProgress(red);
            grEEn.setProgress(green);
            blEu.setProgress(bleu);
        }
    }

    private boolean fileExists(Context context, String filename)
    {
        File file = context.getFileStreamPath(filename);
        if(file == null || !file.exists())
        {
            return false;
        }
        else {
            return true;
        }
    }
    public void save(String FILE_NAME,String text) {
        FileOutputStream fos = null;
        try {
            fos = getActivity().openFileOutput(FILE_NAME, MODE_PRIVATE);
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
    private String load(String FILE_NAME) {
        FileInputStream fis = null;

        try {
            fis = getActivity().openFileInput(FILE_NAME);
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
    @Override
    public void onPause()
    {
        super.onPause();
        if(!saving_fav)
        {
            final AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
            builder.setMessage("Voulez-vous appliquer les réglages ou les abandonner ?")
                    .setTitle("Attention")
                    .setCancelable(true)
                    .setPositiveButton("Appliquer", new DialogInterface.OnClickListener() {
                        public void onClick(final DialogInterface dialog, final int id) {
                            saving_fav();
                            dialog.cancel();
                        }
                    })
                    .setNegativeButton("Abandonner", new DialogInterface.OnClickListener() {
                        public void onClick(final DialogInterface dialog, final int id) {
                            saving_fav=false;
                            dialog.cancel();
                        }
                    });
            final AlertDialog alert = builder.create();
            alert.getWindow().getAttributes().windowAnimations = R.style.popup_window_animation_phone;
            alert.show();
        }
    }
    private void read_colors(){
        FAV1.setText(couleur_name1);
        FAV2.setText(couleur_name2);
        FAV3.setText(couleur_name3);
        FAV4.setText(couleur_name4);
        FAV1.setTextOn(couleur_name1);
        FAV2.setTextOn(couleur_name2);
        FAV3.setTextOn(couleur_name3);
        FAV4.setTextOn(couleur_name4);
        FAV1.setTextOff(couleur_name1);
        FAV2.setTextOff(couleur_name2);
        FAV3.setTextOff(couleur_name3);
        FAV4.setTextOff(couleur_name4);
        fav_ZONE1.setTextOff(Zone_1);
        fav_ZONE1.setTextOn(Zone_1);
        fav_ZONE1.setText(Zone_1);
        fav_ZONE2.setTextOff(Zone_2);
        fav_ZONE2.setTextOn(Zone_2);
        fav_ZONE2.setText(Zone_2);
        fav_ZONE3.setTextOff(Zone_3);
        fav_ZONE3.setTextOn(Zone_3);
        fav_ZONE3.setText(Zone_3);
        fav_ZONE4.setTextOff(Zone_4);
        fav_ZONE4.setTextOn(Zone_4);
        fav_ZONE4.setText(Zone_4);
    }
    public boolean writecharacteristic(int i,int j, String data){
        boolean write=false;
        bleReadWrite=true;
        if (state==0)
        {
            if (mConnected) {
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
            }
        }
        else
        {
            Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
        }

        return write;
    }
    private void sending_on_off(ToggleButton tooglebutton,String sel)
    {
        String Power;
        if(Scene_state==1)
        {
            Toast.makeText(getContext(), " Les Scènes sont Activées. Pour régler vos luminaires à la main veuillez les desactiver ! ", Toast.LENGTH_SHORT).show();
        }else
        if (state==0)
        {
            if (mConnected) {
                if(tooglebutton.isChecked())
                {
                    Power= "{\"light\":[1,0,"+sel+"]}";
                }
                else
                {
                    Power = "{\"light\":[1,1,"+sel+"]}";
                }
                Boolean check;
                do {

                    check=writecharacteristic(SERVICE_WRITE,CHAR_WRITE_LUMINOSITY, Power);
                } while (!check);
            }
        }
        else
        {
            Toast.makeText(getContext(), " Vous êtes en mode Automatique. Pour régler vos luminaires à la main veuillez passer en mode Manuel ! ", Toast.LENGTH_SHORT).show();
        }
    }

    static class MightLight
    {
        int Hue;
        int Sat;
        int Bri;
    }

    static MightLight RgbToHSL(int rgb[])
    {

        MightLight color=new MightLight();
        float R,G,B;

        R = (float)(rgb[0] / 255.0);
        G = (float)(rgb[1] / 255.0);
        B = (float)(rgb[2] / 255.0);

        float min=1000,max=0;
        char cmax='R';

        if (max<R) {max=R;cmax='R';}
        if (max<G) {max=G;cmax='G';}
        if (max<B) {max=B;cmax='B';}

        if (min>R) min=R;
        if (min>G) min=G;
        if (min>B) min=B;

        float Hue=0;

        switch(cmax)
        {
            case 'R': Hue = (G-B)/(max-min);break;
            case 'G': Hue = (float)2.0 + (B-R)/(max-min);break;
            case 'B': Hue = (float)4.0 + (R-G)/(max-min);break;
        }

        Hue*=60;
        if (Hue<0) Hue+=360;

        Hue/=360;

        color.Hue=(int)(255*Hue);

        float lum=((min+max)/2)*100;
        color.Bri=(int)lum;

        float sat;
        if (lum>50) sat= (float)(( max-min)/(2.0-max-min));
        else sat=(max-min)/(max+min);
        sat*=100;
        color.Sat=(int)sat;
        return color;
    }
}
