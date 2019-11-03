import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyRoute extends StatelessWidget {
  static const String routeName = "/privacy";

  @override
  Widget build(BuildContext context) {
    TextStyle bold = Theme.of(context).textTheme.body2.copyWith(
          fontWeight: FontWeight.bold,
        );
    TextStyle link = Theme.of(context).textTheme.body1.copyWith(
          color: Theme.of(context).accentColor,
          decoration: TextDecoration.underline,
        );
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: """
I, Emil Djupvik, built the Find Developers app as a Free app. This SERVICE is provided by me at no cost and is intended for use as is.

This page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.

If you choose to use my Service, then you agree to the collection and use of information concerning this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.

The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Find Developers unless otherwise defined in this Privacy Policy.

""",
                ),
                TextSpan(
                  text: "Information Collection and Use\n\n",
                  style: bold,
                ),
                TextSpan(
                  text: """
For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to email, the city provided by the user, messages with other users, username, user description provided by the user, image URL, push token and user id. The information that I request will be retained on firebase servers.

The app does use third-party services that may collect information used to identify you.

Link to the privacy policy of third party service providers used by the app

""",
                ),
                TextSpan(
                  text: "Google Play Services\n\n",
                  style: link,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final url = "https://policies.google.com/privacy";
                      if (await canLaunch(url)) launch(url);
                    },
                ),
                TextSpan(
                  text: "Firebase Analytics\n\n",
                  style: link,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final url =
                          "https://firebase.google.com/policies/analytics";
                      if (await canLaunch(url)) launch(url);
                    },
                ),
                TextSpan(
                  text: "Log Data\n\n",
                  style: bold,
                ),
                TextSpan(
                  text:
                      """I want to inform you that whenever you use my Service, in the case of an error in the app, I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (\"IP\") address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.

""",
                ),
                TextSpan(
                  text: "Cookies\n\n",
                  style: bold,
                ),
                TextSpan(
                  text: """
Cookies are files with a small amount of data that are commonly used as unique anonymous identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.

This Service does not use these "cookies" explicitly. However, the app may use third party code and libraries that use "cookies" to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.

""",
                ),
                TextSpan(
                  text: "Service Providers\n\n",
                  style: bold,
                ),
                TextSpan(
                  text: """
I may employ third-party companies and individuals due to the following reasons:

  ◯   To facilitate our Service;
  ◯   To provide the Service on our behalf;
  ◯   To perform Service-related services; or
  ◯   To assist us in analyzing how our Service is used.

I want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.

""",
                ),
                TextSpan(
                  text: "Security\n\n",
                  style: bold,
                ),
                TextSpan(
                  text: """
I value your trust in providing us your Personal Information; thus, we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security.

""",
                ),
                TextSpan(
                  text: "Links to Other Sites\n\n",
                  style: bold,
                ),
                TextSpan(
                  text: """
This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. Therefore, I strongly advise you to review the Privacy Policy of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.

""",
                ),
                TextSpan(
                  text: "Children's Privacy\n\n",
                  style: bold,
                ),
                TextSpan(
                  text: """
These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13. In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that I will be able to do the necessary actions.

""",
                ),
                TextSpan(
                  text: "Changes to This Privacy Policy\n\n",
                  style: bold,
                ),
                TextSpan(
                  text: """
I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.

""",
                ),
                TextSpan(
                  text: "Contact Us\n\n",
                  style: bold,
                ),
                TextSpan(
                  text: """
If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me at emil14833@gmail.com.

""",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
