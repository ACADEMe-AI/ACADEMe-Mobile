package profile

import "slices"

type Subject struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

var (
	maths         = Subject{"maths", "Maths"}
	science       = Subject{"science", "Science"}
	socialScience = Subject{"social-science", "Social Science"}
	english       = Subject{"english", "English"}
	hindi         = Subject{"hindi", "Hindi"}
	sanskrit      = Subject{"sanskrit", "Sanskrit"}
	computer      = Subject{"computer", "Computer Applications"}
	physics       = Subject{"physics", "Physics"}
	chemistry     = Subject{"chemistry", "Chemistry"}
	biology       = Subject{"biology", "Biology"}
	historyCivics = Subject{"history-civics", "History & Civics"}
	geography     = Subject{"geography", "Geography"}
	computerSci   = Subject{"computer-science", "Computer Science"}
	accountancy   = Subject{"accountancy", "Accountancy"}
	businessStudy = Subject{"business-studies", "Business Studies"}
	commerce      = Subject{"commerce", "Commerce"}
	economics     = Subject{"economics", "Economics"}
	history       = Subject{"history", "History"}
	politicalSci  = Subject{"political-science", "Political Science"}
	psychology    = Subject{"psychology", "Psychology"}
	physicalEdu   = Subject{"physical-education", "Physical Education"}
	seniorCBSE    = []Subject{physics, chemistry, maths, biology, english, computerSci, accountancy, businessStudy, economics, history, politicalSci, geography, psychology, physicalEdu}
	seniorISC     = []Subject{physics, chemistry, maths, biology, english, computerSci, accountancy, commerce, economics, history, politicalSci, geography, psychology, physicalEdu}
	middleICSE    = []Subject{english, hindi, maths, physics, chemistry, biology, historyCivics, geography, computer}
)

func Subjects(class int, board string) ([]Subject, bool) {
	if class < minClass || class > maxClass || !slices.Contains(Boards, board) {
		return nil, false
	}
	switch {
	case board == "CBSE" && class <= 8:
		return []Subject{maths, science, socialScience, english, hindi, sanskrit}, true
	case board == "CBSE" && class <= 10:
		return []Subject{maths, science, socialScience, english, hindi, sanskrit, computer}, true
	case board == "CBSE":
		return seniorCBSE, true
	case class <= 10:
		return middleICSE, true
	default:
		return seniorISC, true
	}
}
