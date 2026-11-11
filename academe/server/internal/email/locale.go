package email

import applang "academe/server/internal/lang"

type localeCopy struct {
	Lang      string
	Questions string

	WelcomeSubject   string
	WelcomePreheader string
	WelcomeReason    string
	WelcomeGreeting  string
	WelcomeLead      string
	WelcomeBody      string
	OpenButton       string

	ResetSubject    string
	ResetPreheader  string
	ResetReason     string
	ResetHeading    string
	ResetLeadHTML   string
	ResetLeadText   string
	ResetPill       string
	ResetButton     string
	ResetCodePrompt string
	ResetIgnore     string

	GoogleSubject   string
	GooglePreheader string
	GoogleReason    string
	GoogleHeading   string
	GoogleLead      string
	GoogleBefore    string
	GoogleEmphasis  string
	GoogleAfter     string
	GoogleLeadText  string
	GoogleBodyText  string
	GoogleIgnore    string

	DeletionSubject   string
	DeletionPreheader string
	DeletionReason    string
	DeletionHeading   string
	DeletionLead      string
	DeletionOpenTitle string
	DeletionBefore    string
	DeletionPath      string
	DeletionAfter     string
	DeletionCantTitle string
	DeletionCantBody  string
	DeletionButton    string
	DeletionIgnore    string

	FeedbackSubject   string
	FeedbackPreheader string
	FeedbackReason    string
	FeedbackHeading   string
	FeedbackLead      string
	FeedbackNote      string
}

func (c localeCopy) welcomeHeading(name string) string {
	if name == "" {
		return c.WelcomeGreeting + "!"
	}
	return c.WelcomeGreeting + ", " + name + "!"
}

func locale(code string) localeCopy {
	code = applang.Normalize(code)
	if c, ok := locales[code]; ok {
		return c
	}
	return locales["en"]
}

var locales = map[string]localeCopy{
	"en": {
		Lang:      "en",
		Questions: "Questions? Write to",

		WelcomeSubject:   "Welcome to ACADEMe",
		WelcomePreheader: "Your first lesson is ready. Here's how to get started.",
		WelcomeReason:    "You're getting this email because you created an ACADEMe account with this address.",
		WelcomeGreeting:  "Welcome to ACADEMe",
		WelcomeLead:      "I'm Pebby, and I'll be studying with you. Your lessons follow your class and board, in the language you choose.",
		WelcomeBody:      "Swipe through a short lesson, ask me anything you're stuck on, or scan a page from your notebook. A few minutes a day adds up.",
		OpenButton:       "Open ACADEMe",

		ResetSubject:    "Your ACADEMe code is %s",
		ResetPreheader:  "Tap Reset password, or type the code in the app. It expires in 15 minutes.",
		ResetReason:     "You're getting this email because someone asked to reset the password for the ACADEMe account that uses this address.",
		ResetHeading:    "Reset your password",
		ResetLeadHTML:   "Tap the button to choose a new password for your ACADEMe account. The link works once.",
		ResetLeadText:   "Open this link to choose a new password for your ACADEMe account. It works once and expires in 15 minutes:",
		ResetPill:       "Expires in 15 minutes",
		ResetButton:     "Reset password",
		ResetCodePrompt: "Already in the app? Type this code",
		ResetIgnore:     "Didn't ask for this? You can ignore this email. Your password stays the same.",

		GoogleSubject:   "Log in to ACADEMe with Google",
		GooglePreheader: "Your account uses Google to log in, so there's no password to reset.",
		GoogleReason:    "You're getting this email because someone asked to reset the password for the ACADEMe account that uses this address.",
		GoogleHeading:   "Continue with Google",
		GoogleLead:      "Someone asked to reset the password for your ACADEMe account. Your account logs in with Google, so there's no password to reset.",
		GoogleBefore:    "Open ACADEMe and tap ",
		GoogleEmphasis:  "Continue with Google",
		GoogleAfter:     ". Use the Google account for this email address.",
		GoogleLeadText:  "Someone asked to reset the password for your ACADEMe account. Your account logs in with Google, so there's no password to reset.",
		GoogleBodyText:  "Open ACADEMe and tap \"Continue with Google\". Use the Google account for this email address.",
		GoogleIgnore:    "Didn't ask for this? You can ignore this email. Nothing has changed.",

		DeletionSubject:   "Your ACADEMe account deletion request",
		DeletionPreheader: "Reply from this address to confirm, or delete the account in the app.",
		DeletionReason:    "You're getting this email because someone asked on %s to delete the ACADEMe account that uses this address.",
		DeletionHeading:   "We got your deletion request",
		DeletionLead:      "Someone asked to delete the ACADEMe account that uses this email address.",
		DeletionOpenTitle: "Can you open the app?",
		DeletionBefore:    "Go to ",
		DeletionPath:      "Me > Account > Delete my account",
		DeletionAfter:     ". Your account closes straight away and everything is erased after 30 days. Logging in again within those 30 days cancels the deletion.",
		DeletionCantTitle: "Can't open the app?",
		DeletionCantBody:  "Reply to this email from this address to confirm. We'll delete the account and its data and write back within 30 days.",
		DeletionButton:    "Contact support",
		DeletionIgnore:    "Didn't ask for this? You can ignore this email. Nothing will be deleted.",

		FeedbackSubject:   "We got your feedback",
		FeedbackPreheader: "Thanks for writing in. Our team reads every message.",
		FeedbackReason:    "You're getting this email because you sent feedback from the ACADEMe app.",
		FeedbackHeading:   "Thanks, we got your message",
		FeedbackLead:      "Thanks for helping us improve ACADEMe. We read every message and reply from support@academe.cc when we need more detail.",
		FeedbackNote:      "This is not a chat thread. If something is urgent, email support@academe.cc from this address.",
	},
	"hi": {
		Lang:      "hi",
		Questions: "सवाल हैं? लिखें",

		WelcomeSubject:   "ACADEMe में आपका स्वागत है",
		WelcomePreheader: "आपका पहला पाठ तैयार है। शुरू करने का तरीका यह है।",
		WelcomeReason:    "आपको यह ईमेल इसलिए मिल रहा है क्योंकि आपने इस पते से ACADEMe अकाउंट बनाया है।",
		WelcomeGreeting:  "ACADEMe में आपका स्वागत है",
		WelcomeLead:      "मैं Pebby हूँ, और मैं आपके साथ पढ़ूँगी। आपके पाठ आपकी कक्षा और बोर्ड के अनुसार हैं, आपकी चुनी भाषा में।",
		WelcomeBody:      "एक छोटा पाठ स्वाइप करें, जहाँ अटकें मुझसे पूछें, या नोटबुक का पन्ना स्कैन करें। रोज़ थोड़ा समय भी बहुत मदद करता है।",
		OpenButton:       "ACADEMe खोलें",

		ResetSubject:    "आपका ACADEMe कोड है %s",
		ResetPreheader:  "पासवर्ड रीसेट पर टैप करें, या ऐप में कोड टाइप करें। यह 15 मिनट में खत्म हो जाएगा।",
		ResetReason:     "आपको यह ईमेल इसलिए मिल रहा है क्योंकि किसी ने इस पते वाले ACADEMe अकाउंट का पासवर्ड रीसेट करने को कहा।",
		ResetHeading:    "अपना पासवर्ड रीसेट करें",
		ResetLeadHTML:   "नया पासवर्ड चुनने के लिए बटन पर टैप करें। यह लिंक एक बार काम करता है।",
		ResetLeadText:   "अपने ACADEMe अकाउंट के लिए नया पासवर्ड चुनने हेतु यह लिंक खोलें। यह एक बार काम करता है और 15 मिनट में खत्म हो जाता है:",
		ResetPill:       "15 मिनट में खत्म",
		ResetButton:     "पासवर्ड रीसेट करें",
		ResetCodePrompt: "पहले से ऐप में हैं? यह कोड टाइप करें",
		ResetIgnore:     "आपने नहीं माँगा? इस ईमेल को नज़रअंदाज़ करें। आपका पासवर्ड वैसा ही रहेगा।",

		GoogleSubject:   "Google से ACADEMe में लॉग इन करें",
		GooglePreheader: "आपका अकाउंट Google से लॉग इन होता है, इसलिए रीसेट करने के लिए कोई पासवर्ड नहीं है।",
		GoogleReason:    "आपको यह ईमेल इसलिए मिल रहा है क्योंकि किसी ने इस पते वाले ACADEMe अकाउंट का पासवर्ड रीसेट करने को कहा।",
		GoogleHeading:   "Google से जारी रखें",
		GoogleLead:      "किसी ने आपके ACADEMe अकाउंट का पासवर्ड रीसेट करने को कहा। आपका अकाउंट Google से लॉग इन होता है, इसलिए रीसेट करने के लिए कोई पासवर्ड नहीं है।",
		GoogleBefore:    "ACADEMe खोलें और ",
		GoogleEmphasis:  "Google से जारी रखें",
		GoogleAfter:     " पर टैप करें। इस ईमेल पते वाले Google अकाउंट का इस्तेमाल करें।",
		GoogleLeadText:  "किसी ने आपके ACADEMe अकाउंट का पासवर्ड रीसेट करने को कहा। आपका अकाउंट Google से लॉग इन होता है, इसलिए रीसेट करने के लिए कोई पासवर्ड नहीं है।",
		GoogleBodyText:  "ACADEMe खोलें और \"Google से जारी रखें\" पर टैप करें। इस ईमेल पते वाले Google अकाउंट का इस्तेमाल करें।",
		GoogleIgnore:    "आपने नहीं माँगा? इस ईमेल को नज़रअंदाज़ करें। कुछ नहीं बदला है।",

		DeletionSubject:   "आपके ACADEMe अकाउंट हटाने का अनुरोध",
		DeletionPreheader: "पुष्टि के लिए इस पते से जवाब दें, या ऐप में अकाउंट हटाएँ।",
		DeletionReason:    "आपको यह ईमेल इसलिए मिल रहा है क्योंकि किसी ने %s पर इस पते वाले ACADEMe अकाउंट को हटाने को कहा।",
		DeletionHeading:   "हटाने का अनुरोध मिल गया",
		DeletionLead:      "किसी ने इस ईमेल पते वाले ACADEMe अकाउंट को हटाने को कहा।",
		DeletionOpenTitle: "ऐप खोल सकते हैं?",
		DeletionBefore:    "जाएँ ",
		DeletionPath:      "Me > Account > Delete my account",
		DeletionAfter:     "। आपका अकाउंट तुरंत बंद हो जाता है और 30 दिन बाद सब मिट जाता है। उन 30 दिनों में फिर लॉग इन करने से हटाना रद्द हो जाता है।",
		DeletionCantTitle: "ऐप नहीं खोल पा रहे?",
		DeletionCantBody:  "पुष्टि के लिए इस पते से इस ईमेल का जवाब दें। हम अकाउंट और उसका डेटा हटाकर 30 दिनों में जवाब देंगे।",
		DeletionButton:    "सपोर्ट से संपर्क करें",
		DeletionIgnore:    "आपने नहीं माँगा? इस ईमेल को नज़रअंदाज़ करें। कुछ नहीं हटेगा।",

		FeedbackSubject:   "आपका फ़ीडबैक मिल गया",
		FeedbackPreheader: "लिखने के लिए धन्यवाद। हमारी टीम हर संदेश पढ़ती है।",
		FeedbackReason:    "आपको यह ईमेल इसलिए मिल रहा है क्योंकि आपने ACADEMe ऐप से फ़ीडबैक भेजा।",
		FeedbackHeading:   "धन्यवाद, आपका संदेश मिल गया",
		FeedbackLead:      "ACADEMe बेहतर बनाने में मदद के लिए धन्यवाद। हम हर संदेश पढ़ते हैं और ज़रूरत पड़ने पर support@academe.cc से जवाब देते हैं।",
		FeedbackNote:      "यह कोई चैट थ्रेड नहीं है। अगर ज़रूरी हो, तो इस पते से support@academe.cc पर ईमेल करें।",
	},
	"te": {
		Lang:      "te",
		Questions: "ప్రశ్నలున్నాయా? రాయండి",

		WelcomeSubject:   "ACADEMeకి స్వాగతం",
		WelcomePreheader: "మీ మొదటి పాఠం సిద్ధం. మొదలుపెట్టే విధానం ఇది.",
		WelcomeReason:    "ఈ చిరునామాతో ACADEMe అకౌంట్ సృష్టించినందున మీకు ఈ ఇమెయిల్ వస్తోంది.",
		WelcomeGreeting:  "ACADEMeకి స్వాగతం",
		WelcomeLead:      "నేను Pebbyని, మీతో కలిసి చదువుతాను. మీ పాఠాలు మీ తరగతి, బోర్డు ప్రకారం, మీరు ఎంచుకున్న భాషలో ఉంటాయి.",
		WelcomeBody:      "చిన్న పాఠాన్ని స్వైప్ చేయండి, ఇబ్బంది ఉన్న చోట నన్ను అడగండి, లేదా నోట్‌బుక్ పేజీని స్కాన్ చేయండి. రోజుకు కొద్ది నిమిషాలు కూడా లాభం.",
		OpenButton:       "ACADEMe తెరవండి",

		ResetSubject:    "మీ ACADEMe కోడ్ %s",
		ResetPreheader:  "పాస్‌వర్డ్ రీసెట్ నొక్కండి, లేదా యాప్‌లో కోడ్ టైప్ చేయండి. ఇది 15 నిమిషాల్లో ముగుస్తుంది.",
		ResetReason:     "ఈ చిరునామా ఉన్న ACADEMe అకౌంట్ పాస్‌వర్డ్ రీసెట్ చేయమని ఎవరో అడిగినందున మీకు ఈ ఇమెయిల్ వస్తోంది.",
		ResetHeading:    "మీ పాస్‌వర్డ్ రీసెట్ చేయండి",
		ResetLeadHTML:   "కొత్త పాస్‌వర్డ్ ఎంచుకోవడానికి బటన్ నొక్కండి. ఈ లింక్ ఒక్కసారి పనిచేస్తుంది.",
		ResetLeadText:   "మీ ACADEMe అకౌంట్‌కు కొత్త పాస్‌వర్డ్ ఎంచుకోవడానికి ఈ లింక్ తెరవండి. ఇది ఒక్కసారి పనిచేసి 15 నిమిషాల్లో ముగుస్తుంది:",
		ResetPill:       "15 నిమిషాల్లో ముగుస్తుంది",
		ResetButton:     "పాస్‌వర్డ్ రీసెట్",
		ResetCodePrompt: "ఇప్పటికే యాప్‌లో ఉన్నారా? ఈ కోడ్ టైప్ చేయండి",
		ResetIgnore:     "మీరు అడగలేదా? ఈ ఇమెయిల్ విస్మరించండి. మీ పాస్‌వర్డ్ అలాగే ఉంటుంది.",

		GoogleSubject:   "Googleతో ACADEMeలో లాగిన్ అవ్వండి",
		GooglePreheader: "మీ అకౌంట్ Googleతో లాగిన్ అవుతుంది, కాబట్టి రీసెట్ చేయడానికి పాస్‌వర్డ్ లేదు.",
		GoogleReason:    "ఈ చిరునామా ఉన్న ACADEMe అకౌంట్ పాస్‌వర్డ్ రీసెట్ చేయమని ఎవరో అడిగినందున మీకు ఈ ఇమెయిల్ వస్తోంది.",
		GoogleHeading:   "Googleతో కొనసాగించండి",
		GoogleLead:      "మీ ACADEMe అకౌంట్ పాస్‌వర్డ్ రీసెట్ చేయమని ఎవరో అడిగారు. మీ అకౌంట్ Googleతో లాగిన్ అవుతుంది, కాబట్టి రీసెట్ చేయడానికి పాస్‌వర్డ్ లేదు.",
		GoogleBefore:    "ACADEMe తెరిచి ",
		GoogleEmphasis:  "Googleతో కొనసాగించండి",
		GoogleAfter:     " నొక్కండి. ఈ ఇమెయిల్ చిరునామా ఉన్న Google అకౌంట్ వాడండి.",
		GoogleLeadText:  "మీ ACADEMe అకౌంట్ పాస్‌వర్డ్ రీసెట్ చేయమని ఎవరో అడిగారు. మీ అకౌంట్ Googleతో లాగిన్ అవుతుంది, కాబట్టి రీసెట్ చేయడానికి పాస్‌వర్డ్ లేదు.",
		GoogleBodyText:  "ACADEMe తెరిచి \"Googleతో కొనసాగించండి\" నొక్కండి. ఈ ఇమెయిల్ చిరునామా ఉన్న Google అకౌంట్ వాడండి.",
		GoogleIgnore:    "మీరు అడగలేదా? ఈ ఇమెయిల్ విస్మరించండి. ఏమీ మారలేదు.",

		DeletionSubject:   "మీ ACADEMe అకౌంట్ తొలగింపు అభ్యర్థన",
		DeletionPreheader: "నిర్ధారించడానికి ఈ చిరునామా నుండి రిప్లై ఇవ్వండి, లేదా యాప్‌లో అకౌంట్ తొలగించండి.",
		DeletionReason:    "%sలో ఈ చిరునామా ఉన్న ACADEMe అకౌంట్ తొలగించమని ఎవరో అడిగినందున మీకు ఈ ఇమెయిల్ వస్తోంది.",
		DeletionHeading:   "తొలగింపు అభ్యర్థన అందింది",
		DeletionLead:      "ఈ ఇమెయిల్ చిరునామా ఉన్న ACADEMe అకౌంట్ తొలగించమని ఎవరో అడిగారు.",
		DeletionOpenTitle: "యాప్ తెరవగలరా?",
		DeletionBefore:    "వెళ్లండి ",
		DeletionPath:      "Me > Account > Delete my account",
		DeletionAfter:     ". మీ అకౌంట్ వెంటనే మూసివేయబడుతుంది; 30 రోజుల తర్వాత అంతా తుడిచివేయబడుతుంది. ఆ 30 రోజుల్లో మళ్లీ లాగిన్ అయితే తొలగింపు రద్దవుతుంది.",
		DeletionCantTitle: "యాప్ తెరవలేకపోతున్నారా?",
		DeletionCantBody:  "నిర్ధారించడానికి ఈ చిరునామా నుండి ఈ ఇమెయిల్‌కు రిప్లై ఇవ్వండి. మేము అకౌంట్, డేటా తొలగించి 30 రోజుల్లో తిరిగి రాస్తాము.",
		DeletionButton:    "సపోర్ట్‌ను సంప్రదించండి",
		DeletionIgnore:    "మీరు అడగలేదా? ఈ ఇమెయిల్ విస్మరించండి. ఏమీ తొలగించబడదు.",

		FeedbackSubject:   "మీ ఫీడ్‌బ్యాక్ అందింది",
		FeedbackPreheader: "రాసినందుకు ధన్యవాదాలు. మా టీమ్ ప్రతి సందేశం చదువుతుంది.",
		FeedbackReason:    "ACADEMe యాప్ నుండి ఫీడ్‌బ్యాక్ పంపినందున మీకు ఈ ఇమెయిల్ వస్తోంది.",
		FeedbackHeading:   "ధన్యవాదాలు, మీ సందేశం అందింది",
		FeedbackLead:      "ACADEMe మెరుగుపరచడంలో సహాయం చేసినందుకు ధన్యవాదాలు. మేము ప్రతి సందేశం చదివి, అవసరమైతే support@academe.cc నుండి రిప్లై ఇస్తాము.",
		FeedbackNote:      "ఇది చాట్ థ్రెడ్ కాదు. అత్యవసరమైతే ఈ చిరునామా నుండి support@academe.ccకి ఇమెయిల్ చేయండి.",
	},
	"ta": {
		Lang:      "ta",
		Questions: "கேள்விகளா? எழுதுங்கள்",

		WelcomeSubject:   "ACADEMeக்கு வரவேற்கிறோம்",
		WelcomePreheader: "உங்கள் முதல் பாடம் தயார். தொடங்குவது இதோ.",
		WelcomeReason:    "இந்த முகவரியில் ACADEMe கணக்கு உருவாக்கியதால் இந்த மின்னஞ்சல் வருகிறது.",
		WelcomeGreeting:  "ACADEMeக்கு வரவேற்கிறோம்",
		WelcomeLead:      "நான் Pebby; உங்களுடன் படிப்பேன். உங்கள் பாடங்கள் உங்கள் வகுப்பு, வாரியம் மற்றும் நீங்கள் தேர்ந்தெடுத்த மொழியில் இருக்கும்.",
		WelcomeBody:      "சிறிய பாடத்தை ஸ்வைப் செய்யுங்கள், சிக்கலான இடத்தில் என்னிடம் கேளுங்கள், அல்லது நோட்புக் பக்கத்தை ஸ்கேன் செய்யுங்கள். நாளொன்றுக்கு சில நிமிடங்களும் பலன் தரும்.",
		OpenButton:       "ACADEMe திறக்க",

		ResetSubject:    "உங்கள் ACADEMe குறியீடு %s",
		ResetPreheader:  "கடவுச்சொல் மீட்டமை என்பதைத் தட்டவும், அல்லது செயலியில் குறியீட்டை உள்ளிடவும். இது 15 நிமிடங்களில் காலாவதியாகும்.",
		ResetReason:     "இந்த முகவரி உள்ள ACADEMe கணக்கின் கடவுச்சொல்லை மீட்டமைக்க யாரோ கேட்டதால் இந்த மின்னஞ்சல் வருகிறது.",
		ResetHeading:    "கடவுச்சொல்லை மீட்டமைக்கவும்",
		ResetLeadHTML:   "புதிய கடவுச்சொல்லைத் தேர்ந்தெடுக்க பொத்தானைத் தட்டவும். இந்த இணைப்பு ஒரு முறை மட்டும் வேலை செய்யும்.",
		ResetLeadText:   "உங்கள் ACADEMe கணக்கிற்கு புதிய கடவுச்சொல்லைத் தேர்ந்தெடுக்க இந்த இணைப்பைத் திறக்கவும். இது ஒரு முறை வேலை செய்து 15 நிமிடங்களில் காலாவதியாகும்:",
		ResetPill:       "15 நிமிடங்களில் காலாவதி",
		ResetButton:     "கடவுச்சொல் மீட்டமை",
		ResetCodePrompt: "ஏற்கனவே செயலியில் இருக்கிறீர்களா? இந்தக் குறியீட்டை உள்ளிடவும்",
		ResetIgnore:     "நீங்கள் கேட்கவில்லையா? இந்த மின்னஞ்சலைப் புறக்கணியுங்கள். உங்கள் கடவுச்சொல் மாறாது.",

		GoogleSubject:   "Google மூலம் ACADEMeஇல் உள்நுழையுங்கள்",
		GooglePreheader: "உங்கள் கணக்கு Google மூலம் உள்நுழைகிறது; மீட்டமைக்க கடவுச்சொல் இல்லை.",
		GoogleReason:    "இந்த முகவரி உள்ள ACADEMe கணக்கின் கடவுச்சொல்லை மீட்டமைக்க யாரோ கேட்டதால் இந்த மின்னஞ்சல் வருகிறது.",
		GoogleHeading:   "Google உடன் தொடரவும்",
		GoogleLead:      "உங்கள் ACADEMe கணக்கின் கடவுச்சொல்லை மீட்டமைக்க யாரோ கேட்டார்கள். உங்கள் கணக்கு Google மூலம் உள்நுழைகிறது; மீட்டமைக்க கடவுச்சொல் இல்லை.",
		GoogleBefore:    "ACADEMeஐத் திறந்து ",
		GoogleEmphasis:  "Google உடன் தொடரவும்",
		GoogleAfter:     " என்பதைத் தட்டவும். இந்த மின்னஞ்சல் முகவரி உள்ள Google கணக்கைப் பயன்படுத்துங்கள்.",
		GoogleLeadText:  "உங்கள் ACADEMe கணக்கின் கடவுச்சொல்லை மீட்டமைக்க யாரோ கேட்டார்கள். உங்கள் கணக்கு Google மூலம் உள்நுழைகிறது; மீட்டமைக்க கடவுச்சொல் இல்லை.",
		GoogleBodyText:  "ACADEMeஐத் திறந்து \"Google உடன் தொடரவும்\" என்பதைத் தட்டவும். இந்த மின்னஞ்சல் முகவரி உள்ள Google கணக்கைப் பயன்படுத்துங்கள்.",
		GoogleIgnore:    "நீங்கள் கேட்கவில்லையா? இந்த மின்னஞ்சலைப் புறக்கணியுங்கள். எதுவும் மாறவில்லை.",

		DeletionSubject:   "உங்கள் ACADEMe கணக்கு நீக்கக் கோரிக்கை",
		DeletionPreheader: "உறுதிப்படுத்த இந்த முகவரியிலிருந்து பதிலளிக்கவும், அல்லது செயலியில் கணக்கை நீக்கவும்.",
		DeletionReason:    "%sஇல் இந்த முகவரி உள்ள ACADEMe கணக்கை நீக்க யாரோ கேட்டதால் இந்த மின்னஞ்சல் வருகிறது.",
		DeletionHeading:   "நீக்கக் கோரிக்கை கிடைத்தது",
		DeletionLead:      "இந்த மின்னஞ்சல் முகவரி உள்ள ACADEMe கணக்கை நீக்க யாரோ கேட்டார்கள்.",
		DeletionOpenTitle: "செயலியைத் திறக்க முடியுமா?",
		DeletionBefore:    "செல்லுங்கள் ",
		DeletionPath:      "Me > Account > Delete my account",
		DeletionAfter:     ". உங்கள் கணக்கு உடனே மூடப்படும்; 30 நாட்களுக்குப் பிறகு எல்லாம் அழியும். அந்த 30 நாட்களில் மீண்டும் உள்நுழைந்தால் நீக்கம் ரத்து ஆகும்.",
		DeletionCantTitle: "செயலியைத் திறக்க முடியவில்லையா?",
		DeletionCantBody:  "உறுதிப்படுத்த இந்த முகவரியிலிருந்து இந்த மின்னஞ்சலுக்குப் பதிலளிக்கவும். நாங்கள் கணக்கையும் தரவையும் நீக்கி 30 நாட்களில் மீண்டும் எழுதுவோம்.",
		DeletionButton:    "ஆதரவைத் தொடர்புகொள்ளுங்கள்",
		DeletionIgnore:    "நீங்கள் கேட்கவில்லையா? இந்த மின்னஞ்சலைப் புறக்கணியுங்கள். எதுவும் நீக்கப்படாது.",

		FeedbackSubject:   "உங்கள் கருத்து கிடைத்தது",
		FeedbackPreheader: "எழுதியதற்கு நன்றி. எங்கள் குழு ஒவ்வொரு செய்தியையும் படிக்கிறது.",
		FeedbackReason:    "ACADEMe செயலியிலிருந்து கருத்து அனுப்பியதால் இந்த மின்னஞ்சல் வருகிறது.",
		FeedbackHeading:   "நன்றி, உங்கள் செய்தி கிடைத்தது",
		FeedbackLead:      "ACADEMeஐ மேம்படுத்த உதவியதற்கு நன்றி. நாங்கள் ஒவ்வொரு செய்தியையும் படித்து, தேவைப்பட்டால் support@academe.ccஇலிருந்து பதிலளிக்கிறோம்.",
		FeedbackNote:      "இது அரட்டைத் தொடர் அல்ல. அவசரமானால் இந்த முகவரியிலிருந்து support@academe.ccக்கு மின்னஞ்சல் அனுப்புங்கள்.",
	},
	"bn": {
		Lang:      "bn",
		Questions: "প্রশ্ন আছে? লিখুন",

		WelcomeSubject:   "ACADEMe-এ স্বাগতম",
		WelcomePreheader: "তোমার প্রথম পাঠ তৈরি। শুরু করার উপায় এখানে।",
		WelcomeReason:    "এই ঠিকানায় ACADEMe অ্যাকাউন্ট তৈরি করেছ বলে এই ইমেইল আসছে।",
		WelcomeGreeting:  "ACADEMe-এ স্বাগতম",
		WelcomeLead:      "আমি Pebby, তোমার সঙ্গে পড়ব। তোমার পাঠ তোমার ক্লাস ও বোর্ড অনুযায়ী, তুমি বেছে নেওয়া ভাষায়।",
		WelcomeBody:      "ছোট একটি পাঠ সোয়াইপ করো, আটকে গেলে আমাকে জিজ্ঞাসা করো, বা নোটবুকের পাতা স্ক্যান করো। রোজ কিছুক্ষণও কাজে লাগে।",
		OpenButton:       "ACADEMe খুলো",

		ResetSubject:    "তোমার ACADEMe কোড %s",
		ResetPreheader:  "পাসওয়ার্ড রিসেট ট্যাপ করো, বা অ্যাপে কোড টাইপ করো। এটি ১৫ মিনিটে মেয়াদ শেষ হবে।",
		ResetReason:     "এই ঠিকানার ACADEMe অ্যাকাউন্টের পাসওয়ার্ড রিসেট করতে কেউ বলেছে বলে এই ইমেইল আসছে।",
		ResetHeading:    "পাসওয়ার্ড রিসেট করো",
		ResetLeadHTML:   "নতুন পাসওয়ার্ড বেছে নিতে বাটনে ট্যাপ করো। লিঙ্কটি একবার কাজ করে।",
		ResetLeadText:   "তোমার ACADEMe অ্যাকাউন্টের জন্য নতুন পাসওয়ার্ড বেছে নিতে এই লিঙ্ক খোলো। এটি একবার কাজ করে এবং ১৫ মিনিটে মেয়াদ শেষ হয়:",
		ResetPill:       "১৫ মিনিটে মেয়াদ শেষ",
		ResetButton:     "পাসওয়ার্ড রিসেট",
		ResetCodePrompt: "আগে থেকে অ্যাপে আছো? এই কোড টাইপ করো",
		ResetIgnore:     "তুমি চাওনি? এই ইমেইল উপেক্ষা করো। তোমার পাসওয়ার্ড একই থাকবে।",

		GoogleSubject:   "Google দিয়ে ACADEMe-এ লগ ইন করো",
		GooglePreheader: "তোমার অ্যাকাউন্ট Google দিয়ে লগ ইন হয়, তাই রিসেট করার মতো পাসওয়ার্ড নেই।",
		GoogleReason:    "এই ঠিকানার ACADEMe অ্যাকাউন্টের পাসওয়ার্ড রিসেট করতে কেউ বলেছে বলে এই ইমেইল আসছে।",
		GoogleHeading:   "Google দিয়ে চালিয়ে যাও",
		GoogleLead:      "কেউ তোমার ACADEMe অ্যাকাউন্টের পাসওয়ার্ড রিসেট করতে বলেছে। তোমার অ্যাকাউন্ট Google দিয়ে লগ ইন হয়, তাই রিসেট করার মতো পাসওয়ার্ড নেই।",
		GoogleBefore:    "ACADEMe খুলে ",
		GoogleEmphasis:  "Google দিয়ে চালিয়ে যাও",
		GoogleAfter:     " ট্যাপ করো। এই ইমেইল ঠিকানার Google অ্যাকাউন্ট ব্যবহার করো।",
		GoogleLeadText:  "কেউ তোমার ACADEMe অ্যাকাউন্টের পাসওয়ার্ড রিসেট করতে বলেছে। তোমার অ্যাকাউন্ট Google দিয়ে লগ ইন হয়, তাই রিসেট করার মতো পাসওয়ার্ড নেই।",
		GoogleBodyText:  "ACADEMe খুলে \"Google দিয়ে চালিয়ে যাও\" ট্যাপ করো। এই ইমেইল ঠিকানার Google অ্যাকাউন্ট ব্যবহার করো।",
		GoogleIgnore:    "তুমি চাওনি? এই ইমেইল উপেক্ষা করো। কিছুই বদলায়নি।",

		DeletionSubject:   "তোমার ACADEMe অ্যাকাউন্ট মুছে ফেলার অনুরোধ",
		DeletionPreheader: "নিশ্চিত করতে এই ঠিকানা থেকে উত্তর দাও, বা অ্যাপে অ্যাকাউন্ট মুছো।",
		DeletionReason:    "%s-এ এই ঠিকানার ACADEMe অ্যাকাউন্ট মুছে ফেলতে কেউ বলেছে বলে এই ইমেইল আসছে।",
		DeletionHeading:   "মুছে ফেলার অনুরোধ পেয়েছি",
		DeletionLead:      "এই ইমেইল ঠিকানার ACADEMe অ্যাকাউন্ট মুছে ফেলতে কেউ বলেছে।",
		DeletionOpenTitle: "অ্যাপ খুলতে পারো?",
		DeletionBefore:    "যাও ",
		DeletionPath:      "Me > Account > Delete my account",
		DeletionAfter:     "। তোমার অ্যাকাউন্ট সঙ্গে সঙ্গে বন্ধ হয়ে যায় এবং ৩০ দিন পর সব মুছে যায়। সেই ৩০ দিনের মধ্যে আবার লগ ইন করলে মুছে ফেলা বাতিল হয়।",
		DeletionCantTitle: "অ্যাপ খুলতে পারছ না?",
		DeletionCantBody:  "নিশ্চিত করতে এই ঠিকানা থেকে এই ইমেইলের উত্তর দাও। আমরা অ্যাকাউন্ট ও তার ডেটা মুছে ৩০ দিনের মধ্যে জানাব।",
		DeletionButton:    "সাপোর্টে যোগাযোগ করো",
		DeletionIgnore:    "তুমি চাওনি? এই ইমেইল উপেক্ষা করো। কিছুই মুছবে না।",

		FeedbackSubject:   "তোমার ফিডব্যাক পেয়েছি",
		FeedbackPreheader: "লেখার জন্য ধন্যবাদ। আমাদের দল প্রতিটি বার্তা পড়ে।",
		FeedbackReason:    "ACADEMe অ্যাপ থেকে ফিডব্যাক পাঠিয়েছ বলে এই ইমেইল আসছে।",
		FeedbackHeading:   "ধন্যবাদ, তোমার বার্তা পেয়েছি",
		FeedbackLead:      "ACADEMe উন্নত করতে সাহায্য করার জন্য ধন্যবাদ। আমরা প্রতিটি বার্তা পড়ি এবং দরকার হলে support@academe.cc থেকে উত্তর দিই।",
		FeedbackNote:      "এটি চ্যাট থ্রেড নয়। জরুরি হলে এই ঠিকানা থেকে support@academe.cc-এ ইমেইল করো।",
	},
}
