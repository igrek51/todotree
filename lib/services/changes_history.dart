class ChangesHistory {
  bool anyChange = false;

  void clear() {
    anyChange = false;
  }

  void registerChange() {
    anyChange = true;
  }

  bool hasChanges() {
    return anyChange;
  }
}
