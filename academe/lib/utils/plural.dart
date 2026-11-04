String pluralize(int count, String noun) =>
    '$count ${count == 1 ? noun : '${noun}s'}';
