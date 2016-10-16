# class Aozorasearch::GroongaSearcher
#
# Copyright (C) 2016  Masafumi Yokoyama <myokoym@gmail.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

module Aozorasearch
  class GroongaSearcher
    attr_reader :snippet

    def search(database, words, options={})
      books = database.books
      selected_books = select_books(books, words, options)

      @snippet = Groonga::Snippet.new(width: 100,
                                      default_open_tag: "<span class=\"keyword\">",
                                      default_close_tag: "</span>",
                                      html_escape: true,
                                      normalize: true)
      words.each do |word|
        @snippet.add_keyword(word)
      end

      order = options[:reverse] ? "ascending" : "descending"
      sorted_books = selected_books.sort([{
                                            :key => "_score",
                                            :order => order,
                                          }])

      sorted_books
    end

    private
    def select_books(books, words, options)
      selected_books = books.select do |record|
        match_target = record.match_target do |match_record|
            (match_record.index('Terms.Books_title') * 10) |
            (match_record.index('Terms.Books_author_name') * 5) |
            (match_record.index('Terms.Books_content'))
        end
        words.collect do |word|
          match_target =~ word
        end
      end
      selected_books
    end
  end
end
