/**
 * Copyright (C) 2016-2018 Code Defenders contributors
 *
 * This file is part of Code Defenders.
 *
 * Code Defenders is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at
 * your option) any later version.
 *
 * Code Defenders is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Code Defenders. If not, see <http://www.gnu.org/licenses/>.
 */
package org.codedefenders.execution;

import org.codedefenders.util.JavaFileObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Optional;
import java.util.function.BiPredicate;

import javax.tools.JavaCompiler;
import javax.tools.ToolProvider;

import static org.codedefenders.util.Constants.CUTS_DEPENDENCY_DIR;
import static org.codedefenders.util.Constants.F_SEP;
import static org.codedefenders.util.Constants.TEST_CLASSPATH;

/**
 * This class handles compilation of Java classes using the
 * native {@link JavaCompiler}. This class includes a static internal class {@link JavaFileObject}.
 * <p>
 * Offering static methods, java files can be compiled, either by reading the file
 * content from the hard disk or providing it. The resulting {@code .class} is returned.
 * <p>
 * Test cases can also be compiled, but require a reference to the tested class.
 *
 * @author <a href="https://github.com/werli">Phil Werli<a/>
 * @see CompileException
 * @see JavaFileObject
 */
public class Compiler {
    private static final Logger logger = LoggerFactory.getLogger(Compiler.class);

    /**
     * Compiles a java file for a given path. The compiled class
     * is stored in the same directory the specified java file lies.
     *
     * @param javaFilePath Path to the {@code .java} file.
     * @return A path to the {@code .class} file.
     * @throws CompileException If an error during compilation occurs.
     */
    public static String compileJavaFile(String javaFilePath) throws CompileException, IllegalStateException {
        return compileJavaFile(new JavaFileObject(javaFilePath));
    }

    /**
     * Compiles a java file for a given path <i>and</i> file content (so no IO required).
     * The class is stored in the same directory the specified java file lies.
     *
     * @param javaFilePath    Path to the {@code .java} file.
     * @param javaFileContent Content of the {@code .java} file.
     * @return A path to the {@code .class} file.
     * @throws CompileException If an error during compilation occurs.
     */
    public static String compileJavaFileForContent(String javaFilePath, String javaFileContent) throws CompileException, IllegalStateException {
        return compileJavaFile(new JavaFileObject(javaFilePath, javaFileContent));
    }

    /**
     * Before making adjustments:
     * <p>
     * To store the {@code .class} file in the same directory as the {@code .java} file,
     * {@code javac} requires no options, but here, somehow the standard tomcat directory
     * is used, so the option {@code -d} is required.
     */
    @SuppressWarnings("Duplicates")
    private static String compileJavaFile(JavaFileObject javaFile) throws CompileException, IllegalStateException {
        final String outDir = Paths.get(javaFile.getPath()).getParent().toString();
        javax.tools.JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        if (compiler == null) {
            throw new IllegalStateException("Platform provided no java compiler.");
        }

        final StringWriter writer = new StringWriter();
        final List<? extends javax.tools.JavaFileObject> compilationUnits = Arrays.asList(javaFile);
        final List<String> options = Arrays.asList(
                "-encoding", "UTF-8",
                "-d", outDir
        );

        final JavaCompiler.CompilationTask task = compiler.getTask(writer, null, null, options, null, compilationUnits);

        final Boolean success = task.call();
        if (success) {
            try {
                return getClassPath(javaFile);
            } catch (IOException e) {
                throw new CompileException(e);
            }
        } else {
            throw new CompileException(writer.toString());
        }
    }

    /**
     * Compiles a java file for a given java file together with given dependencies.
     * The compiled classes are all stored in the same directory the specified java file lies.
     *
     * @param javaFilePath    Path to the {@code .java} file.
     * @param javaFileContent Content of the {@code .java} file.
     * @param dependencies    a list of {@link JavaFileObject}s, which the given java file is compiled together
     *                        with. All these files must be in the same folder as the given java file.
     * @return A path to the {@code .class} file of the compiled given java file.
     * @throws CompileException If an error during compilation occurs.
     */
    public static String compileJavaFileForContentWithDependencies(String javaFilePath, String javaFileContent, List<JavaFileObject> dependencies) throws CompileException, IllegalStateException {
        return compileJavaFileWithDependencies(new JavaFileObject(javaFilePath, javaFileContent), dependencies, false);
    }

    /**
     * Similar to {@link #compileJavaFileForContentWithDependencies(String, String, List)}, but
     * gives an option to remove the generated {@code .class} files again.
     *
     * @param cleanUpDependencyClassFiles whether generated {@code .class} files of dependencies
     *                                    are removed after compilation. Otherwise they are moved to
     *                                    {@code dependencies/}.
     * @see #compileJavaFileForContentWithDependencies(String, String, List)
     */
    public static String compileJavaFileForContentWithDependencies(String javaFilePath, String javaFileContent, List<JavaFileObject> dependencies, boolean cleanUpDependencyClassFiles) throws CompileException, IllegalStateException {
        return compileJavaFileWithDependencies(new JavaFileObject(javaFilePath, javaFileContent), dependencies, cleanUpDependencyClassFiles);
    }

    /**
     * Compiles a java file for a given path together with given dependencies.
     * The compiled class is stored in the same directory the specified java file lies.
     *
     * @param javaFilePath Path to the {@code .java} file.
     * @param dependencies a list of {@link JavaFileObject}s, which the given java file is compiled together
     *                     with. All these files must be in the same folder as the given java file.
     * @return A path to the {@code .class} file of the compiled given java file.
     * @throws CompileException If an error during compilation occurs.
     */
    public static String compileJavaFileWithDependencies(String javaFilePath, List<JavaFileObject> dependencies) throws CompileException, IllegalStateException {
        return compileJavaFileWithDependencies(new JavaFileObject(javaFilePath), dependencies, false);
    }

    /**
     * Similar to {@link #compileJavaFileWithDependencies(String, List)}, but
     * gives an option to remove the generated {@code .class} files again.
     *
     * @param cleanUpDependencyClassFiles whether generated {@code .class} files of dependencies
     *                                    are removed after compilation. Otherwise they are moved to
     *                                    {@code dependencies/}.
     * @see #compileJavaFileWithDependencies(String, List)
     */
    public static String compileJavaFileWithDependencies(String javaFilePath, List<JavaFileObject> dependencies, boolean cleanUpDependencyClassFiles) throws CompileException, IllegalStateException {
        return compileJavaFileWithDependencies(new JavaFileObject(javaFilePath), dependencies, cleanUpDependencyClassFiles);
    }

    /**
     * Similar to {@link #compileJavaFile(JavaFileObject)}, but the {@code dependency} parameter
     * is added to the compilation units.
     */
    @SuppressWarnings("Duplicates")
    private static String compileJavaFileWithDependencies(JavaFileObject javaFile, List<JavaFileObject> dependencies, boolean cleanUpDependencyClassFiles) throws CompileException, IllegalStateException {
        final String outDir = Paths.get(javaFile.getPath()).getParent().toString();
        javax.tools.JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        if (compiler == null) {
            throw new IllegalStateException("Platform provided no java compiler.");
        }

        final StringWriter writer = new StringWriter();

        final List<javax.tools.JavaFileObject> compilationUnits = new LinkedList<>(dependencies);
        compilationUnits.add(javaFile);

        final List<String> options = Arrays.asList(
                "-encoding", "UTF-8",
                "-d", outDir
        );

        final JavaCompiler.CompilationTask task = compiler.getTask(writer, null, null, options, null, compilationUnits);
        final Boolean success = task.call();

        if (cleanUpDependencyClassFiles) {
            // Remove dependency .class files generated in outDir
            cleanUpDependencies(dependencies, outDir, success);
        } else {
            // Move dependency .class files generated to outDir/dependencies
            moveDependencies(dependencies, outDir, success);
        }
        if (success) {
            try {
                return getClassPath(javaFile);
            } catch (IOException e) {
                throw new CompileException(e);
            }
        } else {
            throw new CompileException(writer.toString());
        }
    }

    /**
     * Compiles a java test file for a given path. The compiled class
     * is stored in the same directory the specified java file lies.
     * <p>
     * Similar to {@link #compileJavaFile(String)}, but includes libraries
     * required for testing.
     *
     * @param javaTestFilePath Path to the {@code .java} test file.
     * @param dependencies     a list of java files required for compilation.
     * @return A path to the {@code .class} file.
     * @throws CompileException If an error during compilation occurs.
     */
    public static String compileJavaTestFile(String javaTestFilePath, List<JavaFileObject> dependencies) throws CompileException, IllegalStateException {
        return compileJavaTestFile(new JavaFileObject(javaTestFilePath), dependencies, false);
    }

    /**
     * Similar to {@link #compileJavaTestFile(String, List)}, but
     * gives an option to remove the generated {@code .class} files again.
     *
     * @param cleanUpDependencyClassFiles whether generated {@code .class} files of dependencies
     *                                    are removed after compilation.
     * @see #compileJavaFileWithDependencies(String, List)
     */
    public static String compileJavaTestFile(String javaTestFilePath, List<JavaFileObject> dependencies, boolean cleanUpDependencyClassFiles) throws CompileException, IllegalStateException {
        return compileJavaTestFile(new JavaFileObject(javaTestFilePath), dependencies, cleanUpDependencyClassFiles);
    }

    /**
     * Compiles a java file for a given path <i>and</i> file content.
     * The class is stored in the same directory the specified java file lies.
     * <p>
     * Similar to {@link #compileJavaFileForContent(String, String)}, but includes libraries
     * required for testing.
     * <p>
     * Removes all {@code .class} files, but the class file of the test case.
     *
     * @param javaFilePath    Path to the {@code .java} test file.
     * @param javaFileContent Content of the {@code .java} test file.
     * @param dependencies    a list of java files required for compilation.
     * @return A path to the {@code .class} file.
     * @throws CompileException If an error during compilation occurs.
     */
    public static String compileJavaTestFileForContent(String javaFilePath, String javaFileContent, List<JavaFileObject> dependencies) throws CompileException, IllegalStateException {
        return compileJavaTestFile(new JavaFileObject(javaFilePath, javaFileContent), dependencies, false);
    }

    /**
     * Similar to {@link #compileJavaTestFileForContent(String, String, List)}, but
     * gives an option to remove the generated {@code .class} files again.
     *
     * @param cleanUpDependencyClassFiles whether generated {@code .class} files of dependencies
     *                                    are removed after compilation.
     */
    public static String compileJavaTestFileForContent(String javaFilePath, String javaFileContent, List<JavaFileObject> dependencies, boolean cleanUpDependencyClassFiles) throws CompileException, IllegalStateException {
        return compileJavaTestFile(new JavaFileObject(javaFilePath, javaFileContent), dependencies, cleanUpDependencyClassFiles);
    }

    /**
     * Just like {@link #compileJavaFileWithDependencies(JavaFileObject, List, boolean)},
     * but includes JUnit, Hamcrest and Mockito libraries required for running the tests.
     */
    @SuppressWarnings("Duplicates")
    private static String compileJavaTestFile(JavaFileObject testFile, List<JavaFileObject> dependencies, boolean cleanUpDependencyClassFiles) throws CompileException, IllegalStateException {
        final String outDir = Paths.get(testFile.getPath()).getParent().toString();

        javax.tools.JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        if (compiler == null) {
            throw new IllegalStateException("Platform provided no java compiler.");
        }

        final StringWriter writer = new StringWriter();
        final List<javax.tools.JavaFileObject> compilationUnits = new LinkedList<>(dependencies);
        compilationUnits.add(testFile);

        final List<String> options = Arrays.asList(
                "-encoding", "UTF-8",
                "-d", outDir,
                "-classpath", TEST_CLASSPATH
        );

        final JavaCompiler.CompilationTask task = compiler.getTask(writer, null, null, options, null, compilationUnits);

        final Boolean success = task.call();
        if (cleanUpDependencyClassFiles) {
            cleanUpDependencies(dependencies, outDir, success);
        }
        if (success) {
            try {
                return getClassPath(testFile);
            } catch (IOException e) {
                throw new CompileException(e);
            }
        } else {
            throw new CompileException(writer.toString());
        }
    }

    /**
     * Removes the {@code .class} files for a given list of files. These files were dependencies
     * for other classes.
     *
     * @param dependencies the {@code .java} files the {@code .class} were generated from
     *                     and will be removed.
     * @param directory    the directory the files were in.
     * @param logError     {@code true} if IOExceptions should be logged.
     */
    private static void cleanUpDependencies(List<JavaFileObject> dependencies, String directory, Boolean logError) {
        for (JavaFileObject dependency : dependencies) {
            try {
                final String path = directory + F_SEP + dependency.getName().replace(".java", ".class");
                logger.info("Removing dependency file:{}", path);
                Files.delete(Paths.get(path));
            } catch (IOException e) {
                if (logError) {
                    logger.warn("Failed to remove dependency class file in folder:{}", directory);
                }
            }
        }
    }

    /**
     * Move generated {@code .class} files to {@code dependencies/} subdirectory for a given list of files.
     *
     * @param dependencies the {@code .java} files the {@code .class} were generated from
     *                     and will be moved.
     * @param directory    the directory the files were in.
     * @param logError     {@code true} if IOExceptions should be logged.
     */
    private static void moveDependencies(List<JavaFileObject> dependencies, String directory, Boolean logError) {
        for (JavaFileObject dependency : dependencies) {
            try {
                final String fileName = dependency.getName().replace(".java", ".class");
                final String oldPath = directory + F_SEP + fileName;
                final String newPath = directory + F_SEP + CUTS_DEPENDENCY_DIR + F_SEP + fileName;
                Files.move(Paths.get(oldPath), Paths.get(newPath));
            } catch (IOException e) {
                if (logError) {
                    logger.error("Failed to move dependency class.", e);
                }
            }
        }
    }

    /**
     * Retrieves the {@code .class} file for a given {@link JavaFileObject}
     * by looking through sub folders and matching file names.
     *
     * @param javaFile the given java file as a {@link JavaFileObject}.
     * @return the path to the {@code .class} of the given java file as a {@link String}.
     * @throws IOException when finding files goes wrong.
     */
    private static String getClassPath(JavaFileObject javaFile) throws IOException {
        final Path startDirectory = Paths.get(javaFile.getPath()).getParent();

        final String targetName = javaFile.getName().replace(".java", ".class");
        final BiPredicate<Path, BasicFileAttributes> matcher = (path, attr) -> path.getFileName().toString().equals(targetName);

        final Optional<Path> first = Files.find(startDirectory, 200, matcher).findFirst();
        if (first.isPresent()) {
            return first.get().toAbsolutePath().toString();
        }
        return javaFile.getPath().replace(".java", ".class");
    }
}
