use std::{collections::VecDeque, mem, str::FromStr};

const PREFIX: &str = "## ";

fn discard_doc(lines: &mut VecDeque<&str>) {
    while let Some(line) = lines.front() {
        if !line.starts_with(PREFIX) && *line != "##" {
            return;
        }
        lines.pop_front().unwrap();
    }
}

fn discard_non_doc(lines: &mut VecDeque<&str>) {
    while let Some(line) = lines.front() {
        if line.starts_with(PREFIX) {
            return;
        }
        lines.pop_front().unwrap();
    }
}

#[derive(Debug)]
pub struct Document {
    modules: Vec<Module>,
}

impl FromStr for Document {
    type Err = &'static str;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut lines = s.lines().collect::<VecDeque<_>>();
        Ok(Self {
            modules: Module::take_all(&mut lines),
        })
    }
}

impl Document {
    fn push_targets_help(s: &mut String, targets: &[Target]) {
        let Some(width) = targets.iter().map(|t| t.name.len()).max() else {
            return;
        };
        for target in targets {
            s.push_str(&format!(
                "{:>width$}: {}\n",
                target.name,
                target.summary,
                width = width + 1
            ));
        }
    }

    /// Format the document as a help text for displaying in a CLI.
    pub fn help(&self) -> String {
        let Self { modules } = self;
        let mut s = String::new();
        let mut first = true;
        for module in modules {
            if !module.targets.is_empty() {
                if !mem::replace(&mut first, false) {
                    s.push('\n');
                }
                s.push_str(&module.name);
                s.push_str(":\n");
                Self::push_targets_help(&mut s, &module.targets);
            }
            for submodule in &module.submodules {
                if !submodule.targets.is_empty() {
                    if !mem::replace(&mut first, false) {
                        s.push('\n');
                    }
                    s.push_str(&submodule.name);
                    s.push_str(":\n");
                    Self::push_targets_help(&mut s, &submodule.targets);
                }
            }
        }
        s
    }
}

#[derive(Debug)]
struct Module {
    name: String,
    targets: Vec<Target>,
    submodules: Vec<Submodule>,
}

impl Module {
    fn take_all(lines: &mut VecDeque<&str>) -> Vec<Self> {
        let mut modules = Vec::new();
        while let Some(module) = Self::take_one(lines) {
            modules.push(module);
        }
        modules
    }

    fn take_one(lines: &mut VecDeque<&str>) -> Option<Self> {
        discard_non_doc(lines);
        let name = lines.front()?.strip_prefix(PREFIX)?;
        let underscore = lines.get(1)?.strip_prefix(PREFIX)?;
        if !underscore.chars().all(|c| c == '=') {
            debug_assert_eq!(underscore.len(), name.len());
            return None;
        }
        discard_doc(lines);

        let targets = Target::take_all(lines);
        let submodules = Submodule::take_all(lines);

        Some(Self {
            name: name.to_string(),
            targets,
            submodules,
        })
    }
}

#[derive(Debug)]
struct Submodule {
    name: String,
    targets: Vec<Target>,
}

impl Submodule {
    fn take_all(lines: &mut VecDeque<&str>) -> Vec<Self> {
        let mut submodules = Vec::new();
        while let Some(submodule) = Self::take_one(lines) {
            submodules.push(submodule);
        }
        submodules
    }

    fn take_one(lines: &mut VecDeque<&str>) -> Option<Self> {
        discard_non_doc(lines);
        let name = lines.front()?.strip_prefix(PREFIX)?;
        let underscore = lines.get(1)?.strip_prefix(PREFIX)?;
        if !underscore.chars().all(|c| c == '-') {
            debug_assert_eq!(underscore.len(), name.len());
            return None;
        }
        discard_doc(lines);

        let targets = Target::take_all(lines);

        Some(Self {
            name: name.to_string(),
            targets,
        })
    }
}

#[derive(Debug)]
struct Target {
    name: String,
    summary: String,
}

impl Target {
    fn title_case(s: &str) -> String {
        let s = s.to_string();
        let mut chars = s.chars().collect::<Vec<_>>();
        if let Some(c) = chars.get_mut(0) {
            c.make_ascii_uppercase();
        }
        chars.into_iter().collect()
    }

    fn take_one(lines: &mut VecDeque<&str>) -> Option<Self> {
        discard_non_doc(lines);
        let summary = lines.front()?.strip_prefix(PREFIX)?;
        if let Some(underscore) = lines.get(1).and_then(|s| s.strip_prefix(PREFIX)) {
            if (underscore.chars().all(|c| c == '=') || underscore.chars().all(|c| c == '-'))
                && !underscore.is_empty()
            {
                return None;
            }
        }
        discard_doc(lines);
        let name = lines.front()?.split_once(':')?.0.to_string();

        Some(Target {
            summary: if summary == "_" {
                Self::title_case(&name).replace('_', " ")
            } else {
                summary.to_string()
            },
            name,
        })
    }

    fn take_all(lines: &mut VecDeque<&str>) -> Vec<Self> {
        let mut targets = Vec::new();
        while let Some(target) = Target::take_one(lines) {
            targets.push(target);
        }
        targets
    }
}

#[cfg(test)]
mod tests {
    use crate::Document;

    #[test]
    fn output_is_correct_for_this_project() {
        let expected = r#"Verbs:
 help: Print help message

Checks:
    check_all: Run all checks
 check_format: Check format
   check_lint: Check lint
   check_docs: Check that documentation can be built
  check_tests: Check that unit tests pass

Fixes:
 fix_format: Fix format
   fix_lint: Fix lint
"#;
        let doc: Document = std::fs::read_to_string("Makefile")
            .unwrap()
            .parse()
            .unwrap();
        let actual = doc.help();
        assert_eq!(actual, expected);
    }
}
