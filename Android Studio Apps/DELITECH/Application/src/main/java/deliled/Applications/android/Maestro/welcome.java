package deliled.Applications.android.Maestro;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import androidx.appcompat.app.AppCompatActivity;
import android.util.Log;
import android.widget.Toast;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;

public class welcome extends AppCompatActivity
{
    String currentVersion;
    String latestVersion;
    public static int is_updated;
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.welcome);
        try {
            currentVersion = getPackageManager().getPackageInfo(getPackageName(), 0).versionName;
        }
        catch (PackageManager.NameNotFoundException e)
        {
            e.printStackTrace();
        }
        ConnectivityManager cm = (ConnectivityManager) this.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        if (activeNetwork != null) {
            // connected to the internet
            new GetVersionCode().execute();
            /*if (activeNetwork.getType() == ConnectivityManager.TYPE_WIFI) {
                // connected to wifi
            } else if (activeNetwork.getType() == ConnectivityManager.TYPE_MOBILE) {
                // connected to mobile data
            }*/
        } else {
            Toast.makeText(welcome.this, "Merci de vous connecter à internet afin d'utiliser l'application Lumi'Air !", Toast.LENGTH_LONG).show();
            is_updated=0;
            // not connected to the internet
        }
        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            public void run()
            {
                Intent intent = new Intent(welcome.this, DeviceScanActivity.class);
                startActivity(intent);
            }
        }, 2000);
    }

    public class GetVersionCode extends AsyncTask<Void, String, String>
    {

        @Override
        protected String doInBackground(Void... voids)
        {

            String newVersion = null;
            try
            {
                is_updated=1;
                Document document = Jsoup.connect("https://play.google.com/store/apps/details?id=" + welcome.this.getPackageName()  + "&hl=en")
                        .timeout(30000)
                        .userAgent("Mozilla/5.0 (Windows; U; WindowsNT 5.1; en-US; rv1.8.1.6) Gecko/20070725 Firefox/2.0.0.6")
                        .referrer("http://www.google.com")
                        .get();
                latestVersion = document.getElementsByClass("htlgb").get(6).text();
                if (document != null)
                {
                    Elements element = document.getElementsContainingOwnText("Current Version");
                    for (Element ele : element)
                    {
                        if (ele.siblingElements() != null)
                        {
                            Elements sibElemets = ele.siblingElements();
                            for (Element sibElemet : sibElemets)
                            {
                                newVersion = sibElemet.text();
                            }
                        }
                    }
                }
            }
            catch (IOException e)
            {
                e.printStackTrace();
            }
            return newVersion;

        }


        @Override
        protected void onPostExecute(String onlineVersion)
        {

            super.onPostExecute(onlineVersion);

            if (onlineVersion != null && !onlineVersion.isEmpty() && isNumeric(onlineVersion))
            {
                if (Float.valueOf(currentVersion) < Float.valueOf(onlineVersion))
                {
                   //show anything
                    is_updated=2;
                }
                else
                {
                    Log.d("update", "Current version : " + currentVersion + " playstore version : " + onlineVersion );
                    is_updated=3;
                }
                Log.d("update", "this version : " + latestVersion );
            }
        }
    }

    public static boolean isNumeric(String strNum) {
        try {
            double d = Double.parseDouble(strNum);
        }
        catch (NumberFormatException | NullPointerException nfe)
        {
            return false;
        }
        return true;
    }
}