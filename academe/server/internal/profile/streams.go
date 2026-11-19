package profile

type Stream struct {
	ID       string    `json:"id"`
	Name     string    `json:"name"`
	Main     []Subject `json:"main"`
	Optional []Subject `json:"optional"`
}

func Streams(class int, board string) ([]Stream, bool) {
	if _, ok := Subjects(class, board); !ok || !senior(class) {
		return nil, false
	}
	business := businessStudy
	if board == "ICSE" {
		business = commerce
	}
	return []Stream{
		{"pcm", "Science · PCM", []Subject{english, physics, chemistry, maths}, []Subject{computerSci, biology, physicalEdu, psychology, economics}},
		{"pcb", "Science · PCB", []Subject{english, physics, chemistry, biology}, []Subject{maths, computerSci, physicalEdu, psychology, economics}},
		{"commerce", "Commerce", []Subject{english, accountancy, business, economics}, []Subject{maths, computerSci, physicalEdu, psychology}},
		{"humanities", "Humanities", []Subject{english, history, politicalSci, geography}, []Subject{economics, psychology, physicalEdu, computerSci, maths}},
	}, true
}
