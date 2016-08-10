module Sovren
  class Client
    def initialize file, options={}
      @client = Savon.client(wsdl:"https://services.resumeparsing.com/ParsingService.asmx?WSDL", :log => false)

      @response = @client.call(:parse_resume, message: { "request" => {
        "AccountId"     => Sovren.configuration.account_id,
        "ServiceKey"    => Sovren.configuration.service_key,
        "FileBytes"     => Base64.encode64(file.read),
        "OutputHtml"    => true,
        "Configuration" => nil,
        "RevisionDate"  => nil,
      } })

      @result = @response.to_hash[:parse_resume_response][:parse_resume_result]

      @doc = Nokogiri::XML(@result[:xml]).remove_namespaces!
    end

    def all
      {
        user: user_info,
        educations: educations,
        internships: internships,
        employments: employments,
      }
    end

    def user_info
      majors = {}

      educations.each do |edu|
        type = edu[:degreeType]
        major = edu[:major]
        if type && major
          if majors[type]
            majors[type] << major
          else
            majors[type] = [major]
          end
        end
      end

      hsh = {
        first_name: @doc.at_css('PersonName GivenName'),
        last_name: @doc.at_css('PersonName FamilyName'),
        name: @doc.at_css('PersonName FormattedName'),
        phone: @doc.at_css('Telephone FormattedNumber') || @doc.at_css('Mobile FormattedNumber'),
        email: @doc.at_css('InternetEmailAddress'),
        majors: majors
      }

      format_hash hsh
    end

    def educations
      @doc.css('SchoolOrInstitution').map do |edu|
        {
          degreeType: edu.at_css('Degree').attr('degreeType'),
          degree: edu.at_css('Degree DegreeName'),
          started_on: edu.at_css('Degree DatesOfAttendance StartDate AnyDate'),
          ended_on: edu.at_css('Degree DatesOfAttendance EndDate AnyDate'),
          major: edu.at_css('Degree DegreeMajor'),
          minor: edu.at_css('Degree DegreeMinor'),
          name: edu.at_css('School SchoolName')
        }
      end.map do |hsh|
        format_hash hsh
      end
    end

    def internships
      positions 'internship'
    end

    def employments
      positions 'directHire'
    end

    def positions type
      @doc.css('PositionHistory').select do |emp|
        emp.attr('positionType') == type
      end.map do |emp|
        {
          "company": emp.at_css('OrgName OrganizationName'),
          "description": emp.at_css('Description'),
          "ended_on": emp.at_css('EndDate AnyDate'),
          "started_on": emp.at_css('StartDate AnyDate'),
          "title": emp.at_css('Title'),
          "current_employer": emp.attr('currentEmployer') == 'true' ? true : false,
        }
      end.map do |hsh|
        format_hash hsh
      end
    end

    def to_xml
      @result[:xml]
    end

private

    def format_hash hash
      formatted = hash.map do |k, v|
        value = if v.blank?
          nil
        elsif [:started_on, :ended_on].include? k
          begin
            Date.strptime(v.text.strip, "%Y-%m-%d")
          rescue ArgumentError
            nil
          end
        elsif v.is_a?(Nokogiri::XML::Element)
          if v.text && !v.text.blank?
            v.text.strip
          else
            nil
          end
        elsif v.is_a?(String)
          if v.blank?
            nil
          else
            v.strip
          end
        else
          v
        end

        [k.to_sym, value]
      end

      Hash[formatted]
    end
  end
end